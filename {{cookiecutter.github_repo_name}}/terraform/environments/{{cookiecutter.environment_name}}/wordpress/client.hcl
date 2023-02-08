#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: create client parameters for a single Wordpress site.
#------------------------------------------------------------------------------
locals {
  wp_hosted_zone_id   = "{{ cookiecutter.wordpress_hosted_zone_id }}"
  wp_domain           = "{{ cookiecutter.wordpress_domain }}"
  wp_subdomain        = "{{ cookiecutter.wordpress_subdomain }}"
  wp_namespace        = "{{ cookiecutter.wordpress_namespace }}"
  wp_username         = "{{ cookiecutter.wordpress_username }}"
  wp_email            = "{{ cookiecutter.wordpress_email }}"
  wp_user_firstname   = "{{ cookiecutter.wordpress_user_firstname }}"
  wp_user_lastname    = "{{ cookiecutter.wordpress_user_lastname }}"
  wp_blog_name        = "{{ cookiecutter.wordpress_blog_name }}"
  wp_database_user    = "{{ cookiecutter.wordpress_database_user }}"
  wp_database         = "{{ cookiecutter.wordpress_database }}"
  wp_disk_volume_size = "{{ cookiecutter.wordpress_disk_volume_size }}"
}
