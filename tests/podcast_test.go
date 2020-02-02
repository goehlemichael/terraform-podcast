package test

import (
// 	"fmt"
	"testing"

// 	"github.com/gruntwork-io/terratest/modules/aws"
// 	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
// 	"github.com/stretchr/testify/assert"
)

// An example of how to test the Terraform module in examples/terraform-aws-example using Terratest.
func TestTerraformAwsExample(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../",

// 		// Variables to pass to our Terraform code using -var options
// 		Vars: map[string]interface{}{
// 			"domain_name": var.domain_name,
// 		},
//
// 		// Environment variables to set when running Terraform
// 		EnvVars: map[string]string{
// 			"AWS_DEFAULT_REGION": awsRegion,
// 		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

}