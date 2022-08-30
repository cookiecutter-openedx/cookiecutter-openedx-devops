Template Notes for Developers
=============================

Take caution when editing these. Keep in mind that these are templates within a template, within a template. That is:
- Cookiecutter (a Jinja templating tool) generates a Terraform template
- The Terraform template generates a bash script that relies on string substitution (another template!)
