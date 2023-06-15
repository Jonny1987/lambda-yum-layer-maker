#!/bin/bash


function add_repos {
    xargs -r yum-config-manager --add-repo < add-repos.txt
    cp -r /etc/yum.repos.d/* /lambda/etc/yum.repos.d
}


function make_layer_zip {
    packages=$1
    for package in $1
    do
        # conditional since previous packages may have installed current one as a dependency
        set +e
        yum list installed $package &> /dev/null
        local is_installed=$?
        set -e

        if [[ $is_installed -eq 1 ]]
        then
            echo installing $package
            yum install -y $package
        else
            echo not installing $package since was already installed previously
        fi
    done
    zip -yr $layer_path /lambda/opt
}


function push_layer_aws {
    local layer_name=$1
    local layer_path=$2
    response=$(aws lambda publish-layer-version --layer-name $layer_name --zip-file fileb://$layer_path --description "$layer_name layer")
}


function make_layer_name {
    local packages_str="$*"
    local layer_name="${packages_str/ /-}"
    echo $layer_name
}

function try_push_layer_aws {
    local packages=$1
    local layer_path=$2
    local size_limit=$3
    local size_bytes=$(stat -c '%s' $layer_path)
    local mb1=$((1024**2))
    local byte_limit=$(($size_limit_mb*$mb1))
    if [[ $size_bytes -le $byte_limit ]]
    then
        local layer_name=$(make_layer_name $packages)
        push_layer_aws $layer_name $layer_path
        echo pushed layer $layer_name to AWS
    else
        local size_mb_str=$(awk -v var1="$size_bytes" -v var2="$mb1" 'BEGIN { print  ( var1 / var2 ) }')
        echo "layer ($size_mb_str mb) too large to push to AWS"
    fi
}

set -e

packages="$@"
mkdir layers
layer_path="/layers/layer.zip"
add_repos
make_layer_zip "${packages[@]}"
size_limit_mb=50
try_push_layer_aws "${packages[@]}" $layer_path $size_limit
