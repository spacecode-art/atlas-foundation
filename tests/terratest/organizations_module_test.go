package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestOrganizationsModulePlanCreatesExpectedResources is plan-only —
// consistent with ADR-0007: no AWS account, real or emulated, supports
// creating an AWS Organization via Terraform, so this asserts against
// the plan JSON rather than applying, the same technique used for the
// iam module (ADR-0008).
func TestOrganizationsModulePlanCreatesExpectedResources(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures/organizations",
		PlanFilePath: "terratest.tfplan",
	})

	planStruct := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	resourceChanges := planStruct.ResourceChangesMap

	// Organization itself
	assert.Contains(t, resourceChanges, "module.organizations.aws_organizations_organization.this")
	org := resourceChanges["module.organizations.aws_organizations_organization.this"]
	assert.Equal(t, "create", string(org.Change.Actions[0]))

	// Organizational Unit, keyed by for_each value
	ouKey := `module.organizations.aws_organizations_organizational_unit.this["TestOU"]`
	assert.Contains(t, resourceChanges, ouKey)
	assert.Equal(t, "create", string(resourceChanges[ouKey].Change.Actions[0]))

	// Account, keyed by for_each value (acct.name)
	acctKey := `module.organizations.aws_organizations_account.this["test-account"]`
	assert.Contains(t, resourceChanges, acctKey)
	assert.Equal(t, "create", string(resourceChanges[acctKey].Change.Actions[0]))
}