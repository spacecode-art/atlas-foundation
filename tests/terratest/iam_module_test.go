package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestIAMModulePlanCreatesExpectedResources(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures/iam",
		PlanFilePath: "terratest.tfplan",
	})

	// InitAndPlanAndShowWithStruct runs init, writes the plan to
	// PlanFilePath, then reads it back as JSON and parses it into a Go
	// struct we can assert against — no apply, no real resources, no
	// cleanup needed. This is the correct technique for a module
	// ADR-0008 documents as design/plan-validated only.
	planStruct := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	resourceChanges := planStruct.ResourceChangesMap
	assert.Contains(t, resourceChanges, `module.iam.aws_ssoadmin_permission_set.this["TestReadOnly"]`)

	permSet := resourceChanges[`module.iam.aws_ssoadmin_permission_set.this["TestReadOnly"]`]
	assert.Equal(t, "create", string(permSet.Change.Actions[0]))
}