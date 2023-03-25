# Environment Specific AWS SES Verified Identity

Creates the following environment specific resources inside of the stack-level Virtual Private Cloud:

- AWS SES Domain identity to establish a "verified identity" for the SES service
- AWS Route53 domain identity DNS record
- AWS Route53 Dkim verification records, so emails we send do not get flagged as spam by recipients

## Note the following

AWS SES service will be initially created in a "sandbox" mode whereby you'll only be able to send a limited number of test emails to email addresses that you've manually verified from the AWS SES console page. You'll need to create a support request to AWS to enable the service for production use. You can initiate this request from the AWS SES console page.

*IMPORTANT*: In our experience AWS tends to be pretty slow about turning this service, and they will often ask follow up questions to which you'll need to respond in a timely manner. Play it safe. Plan for this approval process to take at least three business days, and then be pleasantly surprised if it's approved sooner than that.

## Additional Features

This module integrates [cookiecutter_meta](../../../common/cookiecutter_meta/README.md), which manages an optional additional set of AWS resource tags.
