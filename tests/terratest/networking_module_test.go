package test

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestNetworkingModuleCreatesCorrectSubnetSplit(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures/networking",
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	publicSubnetIDs := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	privateSubnetIDs := terraform.OutputList(t, terraformOptions, "private_subnet_ids")

	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("us-east-1"))
	assert.NoError(t, err)

	client := ec2.NewFromConfig(cfg, func(o *ec2.Options) {
		o.BaseEndpoint = aws.String("http://localhost:4566")
	})

	// Assertion 1: the VPC itself exists with the expected CIDR
	vpcOut, err := client.DescribeVpcs(context.TODO(), &ec2.DescribeVpcsInput{
		VpcIds: []string{vpcID},
	})
	assert.NoError(t, err)
	assert.Len(t, vpcOut.Vpcs, 1)
	assert.Equal(t, "10.99.0.0/16", *vpcOut.Vpcs[0].CidrBlock)

	// Assertion 2: exactly 2 public + 2 private subnets were created
	assert.Len(t, publicSubnetIDs, 2)
	assert.Len(t, privateSubnetIDs, 2)

	// Assertion 3: the actual thing that matters — public subnets auto-
	// assign public IPs, private ones don't. This is the module's entire
	// purpose; if this regresses, the module is broken regardless of
	// resource counts looking right.
	subnetOut, err := client.DescribeSubnets(context.TODO(), &ec2.DescribeSubnetsInput{
		SubnetIds: append(publicSubnetIDs, privateSubnetIDs...),
	})
	assert.NoError(t, err)

	for _, subnet := range subnetOut.Subnets {
		isPublic := contains(publicSubnetIDs, *subnet.SubnetId)
		if isPublic {
			assert.True(t, *subnet.MapPublicIpOnLaunch, "public subnet %s should auto-assign public IPs", *subnet.SubnetId)
		} else {
			assert.False(t, *subnet.MapPublicIpOnLaunch, "private subnet %s should NOT auto-assign public IPs", *subnet.SubnetId)
		}
	}
}

func contains(list []string, item string) bool {
	for _, v := range list {
		if v == item {
			return true
		}
	}
	return false
}