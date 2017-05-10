#! /bin/bash

# Install tools
echo -e "\n*** installing Ubuntu tools ***"
sudo apt-get update && apt-get install wget jq unzip

echo -e "\n*** installing Terraform ***"
install_terraform() {
  local FILE_NAME=terraform_0.7.4_linux_amd64.zip
  wget https://releases.hashicorp.com/terraform/0.7.4/$FILE_NAME
  pwd
  unzip $FILE_NAME -d $(pwd)
  export PATH=$PATH:/build
  terraform -v
}
install_terraform

# Extract previous state
echo -e "\n*** extracting previous state for this job ***"
get_previous_statefile() {
  local previous_statefile_location="/build/previousState/terraform.tfstate"
  if [ -f "$previous_statefile_location" ]; then
    cp $previous_statefile_location /build/IN/repo-tfScripts/gitRepo
    echo 'restored previous statefile'
  else
    echo "no previous statefile exists"
  fi
}
get_previous_statefile

# Extract integration data
echo -e "\n*** extracting AWS integration information ***"
# Load the integration values into environment variables for aws_access_key_id
# and aws_secret_access_key
get_aws_integration() {
  local INTEGRATION_FILE="./IN/integration-aws/integration.env"
  if [ -f "$INTEGRATION_FILE" ]; then
    . $INTEGRATION_FILE
    echo "loaded integration file"
  else
    echo "no integration file exists"
  fi
}
get_aws_integration

# Extract params data
echo -e "\n*** extracting params information ***"
get_params() {
  local PARAMS_FILE="./IN/params-tfScripts/version.json"
  if [ -f "$PARAMS_FILE" ]; then
    PARAMS_VALUES=$(jq -r '.version.propertyBag.params' $PARAMS_FILE)
    PARAMS_LENGTH=$(echo $PARAMS_VALUES | jq '. | length')
    PARAMS_KEYS=$(echo $PARAMS_VALUES | jq '. | keys')
    for (( i=0; i<$PARAMS_LENGTH; i++ )) do
      PARAM_KEY=$(echo $PARAMS_KEYS | jq -r .[$i])
      export $PARAM_KEY=$(echo $PARAMS_VALUES | jq -r .[\"$PARAM_KEY\"])
    done
    echo "loaded params file"
  else
    echo "no params file exists"
  fi
}
get_params

# Provision infrastructure via scripts
echo -e "\n*** provisioning infrastructure on AWS ***"
provision_infra() {
  cd /build/IN/repo-tfScripts/gitRepo
  export AWS_ACCESS_KEY_ID=$aws_access_key_id
  export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
  export AWS_DEFAULT_REGION=$REGION
  terraform apply
}
provision_infra

# Save state
echo -e "\n*** saving state ***"
createOutState() {
  STATEFILE_LOCATION=/build/state/
  cp terraform.tfstate $STATEFILE_LOCATION
}
createOutState

# Save state resource out
echo -e "\n*** saving state resource ***"
createOutStateRes() {
  STATERES_LOCATION=/build/OUT/my-state/state/
  cp terraform.tfstate $STATERES_LOCATION
}
createOutStateRes

# Processing complete
echo -e "\n*** processing complete - ${BASH_SOURCE[0]} ***"
