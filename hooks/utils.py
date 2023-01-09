import os
import shutil


def rm_directory(dir_path: str):
    if os.path.exists(dir_path):
        shutil.rmtree(dir_path)
