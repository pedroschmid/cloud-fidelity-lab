.PHONY: build up down status logs

build:
	docker build -t cloud-fidelity/aws-emulator -f docker/Dockerfile.emulator docker/

up:
	./scripts/bootstrap.sh

down:
	./scripts/cleanup.sh

status:
	docker ps --filter name=cloud-fidelity-emulator

logs:
	docker logs -f cloud-fidelity-emulator

.PHONY: tf-init tf-fmt tf-validate tf-plan tf-apply tf-destroy

tf-init:
	./scripts/terraform.sh init

tf-fmt:
	terraform fmt -recursive infra/

tf-validate:
	./scripts/terraform.sh validate

tf-plan:
	./scripts/terraform.sh plan

tf-apply:
	./scripts/terraform.sh apply

tf-destroy:
	./scripts/terraform.sh destroy
