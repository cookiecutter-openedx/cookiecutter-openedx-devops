# Environment Specific Kubernetes Configuration

Adds Kubernetes [Horizontal Pod Autoscalers](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) and [Vertical Pod Autoscalers](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) to the environment.

## Horizontal Pod Autoscalers

- cms
- cms worker
- lms
- lms worker
- discovery
- mfe
- notes
- smtp

More: see [README](./yml/horizontalpodautoscalers/README.md)

## Vertical Pod Autoscalers

- cms
- cms worker
- lms
- lms worker
- discovery
- ElasticSearch
- MongoDB
- mfe
- notes
- smtp

## Additional Features

This module integrates [cookiecutter_meta](../../../common/cookiecutter_meta/README.md), which manages an optional additional set of AWS resource tags.
