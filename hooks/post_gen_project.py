"""
"""
import os
from .utils import rm_directory

TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "



def remove_k8s_dashboard():
    dir_path = os.path.join("terraform", "stacks", "modules", "kubernetes_dashboard")
    rm_directory(dir_path)

    dir_path = os.path.join("terraform", "environments", "modules", "kubernetes_dashboard")
    rm_directory(dir_path)

def remove_k8s_kubeapps():
    dir_path = os.path.join("terraform", "stacks", "modules", "kubernetes_kubeapps")
    rm_directory(dir_path)

    dir_path = os.path.join("terraform", "environments", "modules", "kubernetes_kubeapps")
    rm_directory(dir_path)

def remove_k8s_karpenter():
    dir_path = os.path.join("terraform", "stacks", "modules", "kubernetes_karpenter")
    rm_directory(dir_path)

    dir_path = os.path.join("terraform", "environments", "modules", "kubernetes_karpenter")
    rm_directory(dir_path)

def remove_k8s_prometheus():
    dir_path = os.path.join("terraform", "stacks", "modules", "kubernetes_prometheus")
    rm_directory(dir_path)

    dir_path = os.path.join("terraform", "environments", "modules", "kubernetes_prometheus")
    rm_directory(dir_path)

def remove_bastion():
    dir_path = os.path.join("terraform", "stacks", "modules", "ec2_bastion")
    rm_directory(dir_path)

    dir_path = os.path.join(
        "terraform", "stacks", "{{ cookiecutter.environment_name }}", "ec2_bastion"
    )
    rm_directory(dir_path)

    dir_path = os.path.join("terraform", "environments", "modules", "ec2_bastion")
    rm_directory(dir_path)

    dir_path = os.path.join(
        "terraform",
        "environments",
        "{{ cookiecutter.environment_name }}",
        "ec2_bastion",
    )
    rm_directory(dir_path)


def remove_mongodb():
    dir_path = os.path.join("terraform", "stacks", "modules", "mongodb")
    rm_directory(dir_path)

    dir_path = os.path.join(
        "terraform",
        "stacks",
        "{{ cookiecutter.global_platform_shared_resource_identifier }}",
        "mongodb",
    )
    rm_directory(dir_path)

    dir_path = os.path.join("terraform", "stacks", "modules", "mongodb_volume")
    rm_directory(dir_path)

    dir_path = os.path.join(
        "terraform",
        "stacks",
        "{{ cookiecutter.global_platform_shared_resource_identifier }}",
        "mongodb_volume",
    )
    rm_directory(dir_path)

    dir_path = os.path.join(
        "terraform", "environments", "{{ cookiecutter.environment_name }}", "mongodb"
    )
    rm_directory(dir_path)

    dir_path = os.path.join("terraform", "environments", "modules", "mongodb")
    rm_directory(dir_path)


def main():
    if "{{ cookiecutter.stack_add_bastion }}".upper() != "Y":
        remove_bastion()

    if "{{ cookiecutter.stack_add_remote_mongodb }}".upper() != "Y":
        remove_mongodb()

    if "{{ cookiecutter.stack_install_k8s_dashboard }}".upper() != "Y":
        remove_k8s_dashboard()

    if "{{ cookiecutter.stack_install_k8s_kubeapps }}".upper() != "Y":
        remove_k8s_kubeapps()

    if "{{ cookiecutter.stack_install_k8s_karpenter }}".upper() != "Y":
        remove_k8s_karpenter()

    if "{{ cookiecutter.stack_install_k8s_prometheus }}".upper() != "Y":
        remove_k8s_prometheus()

    print(SUCCESS + "Your Open edX devops repo has been initialized." + TERMINATOR)


if __name__ == "__main__":
    main()
