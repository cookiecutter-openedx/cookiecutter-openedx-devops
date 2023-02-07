#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: create client parameters for a single Wordpress site.
#------------------------------------------------------------------------------
locals {
  wordpress_hosted_zone_id   = "{{ cookiecutter.wordpress_hosted_zone_id }}"
  wordpress_namespace        = "{{ cookiecutter.wordpress_namespace }}"
  wordpress_username         = "{{ cookiecutter.wordpress_username }}"
  wordpress_email            = "{{ cookiecutter.wordpress_email }}"
  wordpress_user_firstname   = "{{ cookiecutter.wordpress_user_firstname }}"
  wordpress_user_lastname    = "{{ cookiecutter.wordpress_user_lastname }}"
  wordpress_blog_name        = "{{ cookiecutter.wordpress_blog_name }}"
  wordpress_database_user    = "{{ cookiecutter.wordpress_database_user }}"
  wordpress_database         = "{{ cookiecutter.wordpress_database }}"
  wordpress_disk_volume_size = "{{ cookiecutter.wordpress_disk_volume_size }}"
}
