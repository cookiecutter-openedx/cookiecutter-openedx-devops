"""
"""

import os
import shutil


TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "


def remove_clb_files():
    module_dir_path = os.path.join("terraform", "modules", "kubernetes_ingress_clb_controller")
    if os.path.exists(module_dir_path):
        shutil.rmtree(module_dir_path)

    terragrunt_dir_path = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "kubernetes_ingress_clb_controller")
    if os.path.exists(terragrunt_dir_path):
        shutil.rmtree(terragrunt_dir_path)

    ci_dir_path = os.path.join("ci", "tutor-deploy", "environments", "{{ cookiecutter.environment_name }}", "k8s", "kubernetes_clb")
    if os.path.exists(ci_dir_path):
        shutil.rmtree(ci_dir_path)

def remove_alb_files():
    module_dir_path = os.path.join("terraform", "modules", "kubernetes_ingress_alb_controller")
    if os.path.exists(module_dir_path):
        shutil.rmtree(module_dir_path)

    terragrunt_dir_path = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "kubernetes_ingress_alb_controller")
    if os.path.exists(terragrunt_dir_path):
        shutil.rmtree(terragrunt_dir_path)

    ci_dir_path = os.path.join("ci", "tutor-deploy", "environments", "{{ cookiecutter.environment_name }}", "k8s", "kubernetes_alb")
    if os.path.exists(ci_dir_path):
        shutil.rmtree(ci_dir_path)

def remove_ec2_files():
    module_dir_path = os.path.join("terraform", "modules", "kubernetes_ec2")
    if os.path.exists(module_dir_path):
        shutil.rmtree(module_dir_path)

    terragrunt_dir_path = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "kubernetes_ec2")
    if os.path.exists(terragrunt_dir_path):
        shutil.rmtree(terragrunt_dir_path)

    # rename terraform kubernetes_fargate to kubernetes
    old_fargate_module = os.path.join("terraform", "modules", "kubernetes_fargate")
    new_fargate_module = os.path.join("terraform", "modules", "kubernetes")
    if os.path.exists(new_fargate_module):
        shutil.rmtree(new_fargate_module)
    if os.path.exists(old_fargate_module):
        os.rename(old_fargate_module, new_fargate_module)

    # rename terragrunt kubernetes_fargate to kubernetes
    old_fargate_module = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "kubernetes_fargate")
    new_fargate_module = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "kubernetes")
    if os.path.exists(new_fargate_module):
        shutil.rmtree(new_fargate_module)
    if os.path.exists(old_fargate_module):
        os.rename(old_fargate_module, new_fargate_module)

def remove_fargate_files():
    module_dir_path = os.path.join("terraform", "modules", "kubernetes_fargate")
    if os.path.exists(module_dir_path):
        shutil.rmtree(module_dir_path)

    terragrunt_dir_path = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "kubernetes_fargate")
    if os.path.exists(terragrunt_dir_path):
        shutil.rmtree(terragrunt_dir_path)

    terragrunt_alb_dir_path = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "kubernetes_ingress_alb_controller", "terragrunt_fargate.hcl")
    if os.path.exists(terragrunt_alb_dir_path):
        os.remove(terragrunt_alb_dir_path)

    # rename terraform kubernetes_ec2 to kubernetes
    old_ec2_module = os.path.join("terraform", "modules", "kubernetes_ec2")
    new_ec2_module = os.path.join("terraform", "modules", "kubernetes")
    if os.path.exists(new_ec2_module):
        shutil.rmtree(new_ec2_module)
    if os.path.exists(old_ec2_module):
        os.rename(old_ec2_module, new_ec2_module)

    # rename terragrunt kubernetes_ec2 to kubernetes
    old_ec2_module = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "kubernetes_ec2")
    new_ec2_module = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "kubernetes")
    if os.path.exists(new_ec2_module):
        shutil.rmtree(new_ec2_module)
    if os.path.exists(old_ec2_module):
        os.rename(old_ec2_module, new_ec2_module)

# move kubernetes manifests into the k8s folder and remove the original source folder.
def move_manifests(folder = ""):
    source = os.path.join("ci", "tutor-deploy", "environments", "{{ cookiecutter.environment_name }}", "k8s", folder)
    destination = os.path.join("ci", "tutor-deploy", "environments", "{{ cookiecutter.environment_name }}", "k8s")
    src_files = os.listdir(source)
    for file_name in src_files:
        full_file_name = os.path.join(source, file_name)
        if os.path.isfile(full_file_name):
            shutil.copy(full_file_name, destination)
    shutil.rmtree(source)

def main():
    compute_type = "{{ cookiecutter.kubernetes_cluster_compute_type }}".upper()

    if "{{ cookiecutter.kubernetes_cluster_load_balancer_type }}" == "CLB":
        remove_alb_files()
        move_manifests("kubernetes_clb")

    if "{{ cookiecutter.kubernetes_cluster_load_balancer_type }}" == "ALB":
        remove_clb_files()
        move_manifests("kubernetes_alb")

    if (compute_type == "EC2"):
        remove_fargate_files()

    if (compute_type == "FARGATE"):
        remove_ec2_files()

    print(SUCCESS + "Your Open edX devops repo has been initialized." + TERMINATOR)


if __name__ == "__main__":
    main()
