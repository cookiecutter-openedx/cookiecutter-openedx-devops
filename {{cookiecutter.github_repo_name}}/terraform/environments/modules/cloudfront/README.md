# Environment Specific Cloudfront Distribution

Creates a dedicated CDN on a per-environment basis. The following resources are created and configured:

- AWS Cloudfront distribution, sourced by its corresponding AWS S3 Bucket s3://{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-{{ cookiecutter.environment_name }}-storage created in the s3 Terraform module.
- An ssl certificate with preconfigured CNAME, originating from us-east-1 as is required by Cloudfront
- A DNS record added to the environment AWS Route53 Hosted Zone

## Note the following

The AWS S3 bucket is configured to allow publicly accessible content. However, you must manually and explicitly make content public in order for it to be viewable from the CDN created by this module. Moreover, you should remain aware that this bucket by default contains a collections of mixed content originating from various parts of the openedx platform, including profile images, course content, grade downloads, and so on. It is possible to customize this behavior in order to segregate content that you may deem too sensitive. See [openedx-actions/tutor-plugin-enable-s3](https://github.com/openedx-actions/tutor-plugin-enable-s3), called from Github Actions Deployment workflows in this repo.

## Additional Features

This module integrates [cookiecutter_meta](../../../common/cookiecutter_meta/README.md), which manages an optional additional set of AWS resource tags.
