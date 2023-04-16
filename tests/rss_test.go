package test

import (
// 	"fmt"
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestPodcast(t *testing.T) {
	t.Parallel()
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/single_podcast_aws",
		VarFiles: []string{"vars/mike.tfvars"},
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
