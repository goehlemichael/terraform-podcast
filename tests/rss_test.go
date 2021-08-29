package test

import (
// 	"fmt"
	"testing"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestPodcast(t *testing.T) {
	t.Parallel()
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../",
	})
	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)
	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)
	// Run `terraform output` to get the RSS/XML feed for the podcast
	podcast_url := terraform.Output(t, terraformOptions, "podcast_url")
// 	content_bucket_url := terraform.Output(t, terraformOptions, "content_bucket_url")
// 	log_bucket_url := terraform.Output(t, terraformOptions, "log_bucket_url")
	// Make an HTTP request to the rss feed and validate no errors occur
// 	url := fmt.Sprintf("%s", podcast_url)
	http_helper.HttpGetE(t, podcast_url, nil)

}
