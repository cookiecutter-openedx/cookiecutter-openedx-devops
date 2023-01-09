"""
"""
import os
from .utils import rm_directory

TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "

github_repo_name = "{{ cookiecutter.github_repo_name }}"
if hasattr(github_repo_name, "isidentifier"):
    assert (
        github_repo_name.isidentifier()
    ), "'{}' project slug is not a valid Python identifier.".format(github_repo_name)

assert (
    github_repo_name == github_repo_name.lower()
), "'{}' project slug should be all lowercase".format(github_repo_name)

def reinitialize(repo_path):
    if os.path.exists(repo_path):
      print(INFO + "reinitializing the repository folder {folder}" + TERMINATOR.format(
        folder=repo_path
      ))
      rm_directory(repo_path)

def main():
    """
    If we find an existing repository then we should preemptively delete the existing
    Cookiecutter output in order to avoid situations where deleted, deprecated, or relocated
    template files would otherwise remain as 'residue' of the Cookiecutter output.
    """
    print(INFO + "Open edX devops Cookiecutter" + TERMINATOR)

    repo_path = os.path.join("{{ cookiecutter.github_repo_name }}")
    if not os.path.exists(repo_path):
      return

    print(INFO + "Open edX devops found an existing repository {{ cookiecutter.github_repo_name }}." + TERMINATOR)

    terraform_path = os.path.join("{{ cookiecutter.github_repo_name }}", "terraform")
    reinitialize(terraform_path)

    github_path = os.path.join("{{ cookiecutter.github_repo_name }}", ".github")
    reinitialize(github_path)

    ci_path = os.path.join("{{ cookiecutter.github_repo_name }}", "ci")
    reinitialize(ci_path)

    scripts_path = os.path.join("{{ cookiecutter.github_repo_name }}", "scripts")
    reinitialize(scripts_path)

    print(INFO + "Open edX devops has reinitialized the repository cookiecutter.github_repo_name" + TERMINATOR)

if __name__ == "__main__":
    main()
