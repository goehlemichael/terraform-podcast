MARKDOWNLINT_IMAGE=markdownlint/markdownlint:latest

.PHONY: markdownlint
markdownlint:
	@(docker run --rm -v `pwd`:/data ${MARKDOWNLINT_IMAGE} .)
