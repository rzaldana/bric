.PHONY: test

.container_tag: Dockerfile
	@echo "BUILDING TEST ENVIRONMENT CONTAINER"
	@docker build -t new_test .
	@echo "new_test" > .container_tag

test: .container_tag
	@echo "RUNNING TESTS"
	@docker run --rm -t -v ../:/var/task --entrypoint /bin/bash $$(< .container_tag) -- bash_unit ./test/test_bootstrap.bash
