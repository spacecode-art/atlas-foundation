//go:build ministack_unsafe_rds

// This file is excluded from the default build (no ministack_unsafe_rds
// build tag = not compiled, not just not run). See ADR-0017, ADR-0018,
// ADR-0019. Run deliberately via `make test-database-unsafe`, never via
// plain `make test` / `make check`, and never against a MiniStack
// instance holding anything you care about.

package test

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/rds"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestDatabaseModuleCreatesEncryptedPrivateInstance(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures/database",
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("us-east-1"))
	assert.NoError(t, err)

	client := rds.NewFromConfig(cfg, func(o *rds.Options) {
		o.BaseEndpoint = aws.String("http://localhost:4566")
	})

	out, err := client.DescribeDBInstances(context.TODO(), &rds.DescribeDBInstancesInput{
		DBInstanceIdentifier: aws.String("atlas-terratest-db-db"),
	})
	assert.NoError(t, err)
	assert.Len(t, out.DBInstances, 1)

	instance := out.DBInstances[0]

	// The three properties that actually matter for security, not just
	// "does it exist"
	assert.True(t, *instance.StorageEncrypted, "database storage must be encrypted")
	assert.False(t, *instance.PubliclyAccessible, "database must not be publicly accessible")
	assert.NotNil(t, instance.MasterUserSecret, "database must use Secrets Manager, not a plaintext password")
}