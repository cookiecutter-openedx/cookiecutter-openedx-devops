Template Notes for Developers
=============================

Take caution when editing these. Keep in mind that these are templates within a template, within a template. That is:
- Cookiecutter (a Jinja templating tool) generates a Terraform template
- The Terraform template generates a bash script that relies on string substitution (another template!)


Notes:
  - THESE ARE JINJA TEMPLATE DIRECTIVES
     some source code that violates some Jinja rendering rule(s)

  - THIS IS A TERRAFORM TEMPLATING DIRECTIVE
    $${some_bash_variable_that_should_not_be_substituted_by_terraform}
