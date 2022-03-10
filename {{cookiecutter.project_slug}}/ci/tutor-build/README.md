# tutor-build
## Stepwise Math Tutor image building

This repository contains a GitHub actions workflow that assists with the process of building a custom docker image for Open edX. It essentially captures what is described in Tutor's official documentation [here](https://docs.tutor.overhang.io/configuration.html#custom-open-edx-docker-image).

## Why do we need a custom image.
We need a custom image because we need to pack a custom [theme](https://github.com/stepwisemath/stepwise-edx-theme) and
an integration [plug-in](https://github.com/stepwisemath/stepwise-edx-plugin) for edx-platform.
The contents of these two repositories need to be included in the resulting image.

## How it works
All the logic is packed in the actual workflow. It mostly follows the steps outlined on Tutor's documentation with some
adaptations to run it in a disposable CI environment.

When running the Tutor CLI in a local machine it can run in an interactive mode and persists the captured config into a local file.
In the context of a CI job, such as GitHub Actions, this is not possible.

Luckily the Tutor CLI allows all of it's params to be passed as a command line argument, or as an environment variable.
We leverage this feature to provide all the custom details, from external sources.

## Building an image
To manually trigger the build of a new image, we need to head to [GitHub's actions tab](https://github.com/stepwisemath/tutor-build/actions)
in this repo, select the `Build Tutor Docker image` workflow, and click the "Run workflow" button.

An image will be built and pushed to the ECR repo defined on the Workflow definition.

The docker image tag will be automatically suffixed with a timestamp. The full location of the pushed image, and its
unique docker tag can be visualised in the last user defined step of the workflow.

This value then needs to be updated on the target environment's configuration on the [deployment repository](https://github.com/stepwisemath/tutor-deploy).

