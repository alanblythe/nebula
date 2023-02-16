#!/bin/bash

set -e
ENVIRONMENT_NAME=$1

export LOCATION=eastus2
export COMMON_RESOURCE_GROUP_NAME="rg-nebula-terraform-$ENVIRONMENT_NAME"
export TF_STATE_STORAGE_ACCOUNT_NAME="nebula${ENVIRONMENT_NAME}tfstate1458"
export TF_STATE_CONTAINER_NAME=tfstate
export KEYVAULT_NAME=kv-nebula1458-tf-dev
