
clean:
	find . -name ".terragrunt-cache" -type d -exec rm -rf {} \;
	find . -name ".terraform" -type d -exec rm -rf {} \;
	find . -name ".terraform.lock.hcl" -type f -exec rm  {} \;

lint:
	make lint-terraform
	make pre-commit

lint-terraform:
	terraform fmt -recursive

pre-commit:
	pre-commit install
	pre-commit autoupdate
	pre-commit run --all-files

######################
# HELP
######################

help:
	@echo '===================================================================='
	@echo 'clean               - remove all Terraform caches and artifacts'
	@echo 'lint                - run all code linters and formatters'
