MARKDOWNLINT_IMAGE=markdownlint/markdownlint:latest
PODCAST_NAME=example

.PHONY: markdownlint
markdownlint:
	@(docker run --rm -v `pwd`:/data ${MARKDOWNLINT_IMAGE} .)

.PHONY: test
test:
	@cd tests;go test -p 1 -v -count=1 -timeout 30m

.PHONY: plan
plan:
	@cd examples/single_podcast_aws;terraform plan -var-file="${PODCAST_NAME}.tfvars"

.PHONY: apply
apply:
	@cd examples/single_podcast_aws;terraform apply -var-file="${PODCAST_NAME}.tfvars"

.PHONY: destroy
destroy:
	@cd examples/single_podcast_aws;terraform destroy -var-file="${PODCAST_NAME}.tfvars"
