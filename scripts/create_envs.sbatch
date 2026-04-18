#!/bin/bash
set -euo pipefail

ENV_DIR="envs"

for yaml in ${ENV_DIR}/*.yaml; do
    echo "===================================="
    echo "Creating environment from: $yaml"
    
    # extract the env name from each YAML
    env_name=$(grep "^name:" "$yaml" | awk '{print $2}')

    if [ -z "$env_name" ]; then
        echo "ERROR: No environment name found in $yaml"
        exit 1
    fi

    echo "Environment name: $env_name"

    # use mamba to create the envs for non-wrapper rules
    mamba env create -f "$yaml"

    echo "Done: $env_name"
done

echo "environments created :))"
