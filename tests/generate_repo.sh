#------------------------------------------------------------------------------
# written by:   mcdaniel
# date:         mar-2022
#
# usage:        Cookiecut to a sandox VPC in the Stepwise AWS account.
#               Add your own personalized cookiecutter.json to this folder
#------------------------------------------------------------------------------

GITHUB_REPO="https://github.com/lpm0073/cookiecutter-openedx-devops"
GITHUB_BRANCH="eks-fargate"
OUTPUT_FOLDER="/Users/mcdaniel/cookiecutter/"

cookiecutter $GITHUB_REPO \
             --checkout $GITHUB_BRANCH \
             --output-dir $OUTPUT_FOLDER \
             --directory tests \
             --overwrite-if-exists \
             --no-input 
