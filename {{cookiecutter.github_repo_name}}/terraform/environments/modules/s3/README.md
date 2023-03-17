# Environment Specific Remote Storage

Creates dedicated AWS S3 Buckets for storage, backups, and secrets management. Creates the following resources:

- s3://{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-{{ cookiecutter.environment_name }}-storage
- s3://{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-{{ cookiecutter.environment_name }}-backups
- s3://{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-{{ cookiecutter.environment_name }}-secrets
- AWS IAM user + key-secret to facilitate programatic bucket access via awscli from within Open edX software
- Kubernetes secret created with the namespace for this environment, containing all AWS S3 bucket meta data and credentials

## Note the following

The AWS S3 bucket is configured to allow publicly accessible content. However, you must manually and explicitly make content public in order for it to be viewable from the CDN created by this module. Moreover, you should remain aware that this bucket by default contains a collections of mixed content originating from various parts of the openedx platform, including profile images, course content, grade downloads, and so on. It is possible to customize this behavior in order to segregate content that you may deem too sensitive. See [openedx-actions/tutor-plugin-enable-s3](https://github.com/openedx-actions/tutor-plugin-enable-s3) and [hastexo/tutor-contrib-s3](https://github.com/hastexo/tutor-contrib-s3), called from Github Actions Deployment workflows in this repo.

## Additional Features

This module integrates [cookiecutter_meta](../../../common/cookiecutter_meta/README.md), which manages an optional additional set of AWS resource tags.
