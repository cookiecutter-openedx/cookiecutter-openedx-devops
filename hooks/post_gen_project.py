"""
"""

import os
import shutil


TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "


def remove_eks_clb_ec2_files():
    component_dir_path = os.path.join("terraform", "components", "eks_clb_ec2")
    if os.path.exists(component_dir_path):
        shutil.rmtree(component_dir_path)

    terragrunt_dir_path = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "eks_clb_ec2")
    if os.path.exists(terragrunt_dir_path):
        shutil.rmtree(terragrunt_dir_path)

    ci_dir_path = os.path.join("ci", "tutor-deploy", "environments", "{{ cookiecutter.environment_name }}", "k8s", "eks_clb_ec2")
    if os.path.exists(ci_dir_path):
        shutil.rmtree(ci_dir_path)

def remove_eks_alb_ec2_files():
    component_dir_path = os.path.join("terraform", "components", "eks_alb_ec2")
    if os.path.exists(component_dir_path):
        shutil.rmtree(component_dir_path)

    terragrunt_dir_path = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "eks_alb_ec2")
    if os.path.exists(terragrunt_dir_path):
        shutil.rmtree(terragrunt_dir_path)

    ci_dir_path = os.path.join("ci", "tutor-deploy", "environments", "{{ cookiecutter.environment_name }}", "k8s", "eks_alb_ec2")
    if os.path.exists(ci_dir_path):
        shutil.rmtree(ci_dir_path)

def remove_eks_abl_fargate_files():
    component_dir_path = os.path.join("terraform", "components", "eks_alb_fargate")
    if os.path.exists(component_dir_path):
        shutil.rmtree(component_dir_path)

    terragrunt_dir_path = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "eks_alb_fargate")
    if os.path.exists(terragrunt_dir_path):
        shutil.rmtree(terragrunt_dir_path)

    ci_dir_path = os.path.join("ci", "tutor-deploy", "environments", "{{ cookiecutter.environment_name }}", "k8s", "eks_alb_fargate")
    if os.path.exists(ci_dir_path):
        shutil.rmtree(ci_dir_path)

# move kubernetes manifests into the k8s folder and remove the original source folder.
def move_manifests(folder = ""):
    source = os.path.join("ci", "tutor-deploy", "environments", "{{ cookiecutter.environment_name }}", "k8s", folder)
    destination = os.path.join("ci", "tutor-deploy", "environments", "{{ cookiecutter.environment_name }}", "k8s")
    shutil.copy(source + "/*", destination)
    shutil.rmtree(source)

def main():

    if "{{ cookiecutter.eks_cluster_compute_type }}" == "CLB_EC2":
        remove_eks_abl_fargate_files()
        remove_eks_alb_ec2_files()
        move_manifests("eks_clb_ec2")

    if "{{ cookiecutter.eks_cluster_compute_type }}" == "ALB_EC2":
        remove_eks_abl_fargate_files()
        remove_eks_clb_ec2_files()
        move_manifests("eks_alb_ec2")

    if "{{ cookiecutter.eks_cluster_compute_type }}" == "ALB_Fargate":
        remove_eks_clb_ec2_files()
        remove_eks_alb_ec2_files()
        move_manifests("eks_alb_fargate")

    print(SUCCESS + "Your Open edX devops repo has been initialized." + TERMINATOR)


if __name__ == "__main__":
    main()
