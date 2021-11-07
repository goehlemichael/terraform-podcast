MARKDOWNLINT_IMAGE=markdownlint/markdownlint:latest

.PHONY: markdownlint
markdownlint:
	@(docker run --rm -v `pwd`:/data ${MARKDOWNLINT_IMAGE} .)

.PHONY: test
test:
	@go test -p 1 -v -count=1 -timeout 30m

.PHONY: plan
plan:
	@terraform plan -var-file="${PODCAST_NAME.tfvars}"