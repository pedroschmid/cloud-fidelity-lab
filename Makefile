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
