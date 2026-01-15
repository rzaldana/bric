.PHONY: test

.container_tag: ./test/Dockerfile
	@echo "BUILDING TEST ENVIRONMENT CONTAINER"
	@docker build -t new_test ./test
	@echo "new_test" > .container_tag

bootstrap: ./src/bootstrap
	./submodules/blink/blink ./src/bootstrap ./bootstrap

test: .container_tag bootstrap
	@echo "RUNNING TESTS"
	@docker run --rm -t -v ./:/var/task --entrypoint /bin/bash $$(< .container_tag) -- bash_unit ./test/test_bootstrap.bash
