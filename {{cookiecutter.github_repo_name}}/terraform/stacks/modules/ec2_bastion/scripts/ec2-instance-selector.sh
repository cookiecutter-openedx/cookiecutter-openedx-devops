ec2-instance-selector --memory-min 8 --memory-max 16 --vcpus-min 2 --vcpus-max 4 --cpu-architecture x86_64 --region {{ cookiecutter.global_aws_region }} --max-results 100 -o table-wide
