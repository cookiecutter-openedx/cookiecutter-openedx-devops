#!/bin/bash
#---------------------------------------------------------
#
# Push and tag the newly created Docker image.
#
#---------------------------------------------------------
tutor images push openedx
docker tag ${AWS_ECR_REGISTRY_OPENEDX}/${AWS_ECR_REPOSITORY_OPENEDX}:${REPOSITORY_TAG_OPENEDX} ${AWS_ECR_REGISTRY_OPENEDX}/${AWS_ECR_REPOSITORY_OPENEDX}:latest
docker push ${AWS_ECR_REGISTRY_OPENEDX}/${AWS_ECR_REPOSITORY_OPENEDX}:latest
