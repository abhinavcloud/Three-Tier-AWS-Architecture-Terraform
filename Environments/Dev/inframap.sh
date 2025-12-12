#Check if the terrafrom state file exists in the S3 bucket or not
if aws s3 ls s3://my-terraform-state-bucket/dev/terraform.tfstate 2>&1 | grep -q 'NoSuchBucket\|Not Found'; then
    echo "Terraform state file does not exist in the S3 bucket."
    teraform init
    terraform apply -auto-approve
    terraform state pull > inframap-tfstate.json
    echo "Generating infrastructure map using Inframap."
    inframap generate inframap-tfstate.json > inframap-dev.dot
    echo "Converting DOT file to PNG format."
    dot -Tpng inframap-dev.dot -o inframap-dev.png
    echo "Infrastructure map generated successfully with filename inframap-dev.png"
else
    echo "Terraform state file exists in the S3 bucket."
    echo "Pulling the latest state file from S3."
    terraform init
    terraform state pull > inframap-tfstate.json
    echo "Generating infrastructure map using Inframap."
    inframap generate -t aws -s inframap-tfstate.json -o inframap-dev.dot
    echo "Converting DOT file to PNG format."
    dot -Tpng inframap-dev.dot -o inframap-dev.png  
    echo "Infrastructure map generated successfully with filename inframap-dev.png"

fi