"""
"""

import os
import shutil


TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "

def remove_bastion():
    module_dir_path = os.path.join("terraform", "modules", "ec2_bastion")
    if os.path.exists(module_dir_path):
        shutil.rmtree(module_dir_path)

    terragrunt_dir_path = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "ec2_bastion")
    if os.path.exists(terragrunt_dir_path):
        shutil.rmtree(terragrunt_dir_path)

def remove_dynamodb():
    module_dir_path = os.path.join("terraform", "modules", "mongodb")
    if os.path.exists(module_dir_path):
        shutil.rmtree(module_dir_path)

    terragrunt_dir_path = os.path.join("terraform", "environments", "{{ cookiecutter.environment_name }}", "mongodb")
    if os.path.exists(terragrunt_dir_path):
        shutil.rmtree(terragrunt_dir_path)


def main():
    if "{{ cookiecutter.environment_add_bastion }}".upper() != "Y":
        remove_bastion()

    if "{{ cookiecutter.environment_add_documentdb }}".upper() != "Y":
        remove_dynamodb()

    print(SUCCESS + "Your Open edX devops repo has been initialized." + TERMINATOR)


if __name__ == "__main__":
    main()
