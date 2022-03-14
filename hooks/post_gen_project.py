"""
"""

import os
import shutil


TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "


def remove_eks_ec2_files():
    component_dir_path = os.path.join("terraform", "components", "eks")
    if os.path.exists(component_dir_path):
        shutil.rmtree(component_dir_path)

    terragrunt_dir_path = os.path.join("terraform", "environments", "prod", "eks")
    if os.path.exists(terragrunt_dir_path):
        shutil.rmtree(terragrunt_dir_path)

def remove_eks_fargate_files():
    component_dir_path = os.path.join("terraform", "components", "eks_fargate")
    if os.path.exists(component_dir_path):
        shutil.rmtree(component_dir_path)

    terragrunt_dir_path = os.path.join("terraform", "environments", "prod", "eks_fargate")
    if os.path.exists(terragrunt_dir_path):
        shutil.rmtree(terragrunt_dir_path)



def main():

    if "{{ cookiecutter.eks_cluster_compute_type }}" == "EC2":
        remove_eks_fargate_files()
    if "{{ cookiecutter.eks_cluster_compute_type }}" == "Fargate":
        remove_eks_ec2_files()

    print(SUCCESS + "Your Open edX devops repo has been initialized. Now is a good opportunity to 'git init / add / commit / push to GitHub'." + TERMINATOR)


if __name__ == "__main__":
    main()
