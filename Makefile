DOCKER ?= docker
TARGET ?= janus-centos7
AWS ?= aws

all: 
	@echo "Building ${TARGET}"
	$(DOCKER) build -t $(TARGET) -f Dockerfile .

push:
	$(DOCKER) tag janus-centos7:latest public.ecr.aws/v9t8r4d5/janus-centos7:latest

	$(AWS) ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/v9t8r4d5
	$(DOCKER) push public.ecr.aws/v9t8r4d5/janus-centos7:latest

task:	
	$(DOCKER) aws ecs register-task-definition --cli-input-json file://janus.json
