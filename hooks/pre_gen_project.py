"""
"""

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
