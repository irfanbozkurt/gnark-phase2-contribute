#!/bin/bash

# Check if Go is installed
if ! command -v go &>/dev/null; then
    echo "Go is not installed."
    echo "Please install Go and try again -> https://go.dev/doc/install"
    exit 1
fi

# Check if git is installed
if ! git --version 2>&1 >/dev/null ; then 
   echo "Git is not installed."
   echo "Please install Git and try again."
   exit 1
fi

# Source the .env file exists
env_file=$(ls contribution_*.env 2> /dev/null | head -n 1)
if [ -n "$env_file" ]; then
    source $env_file
else
    echo "No contribution_*.env file exists."
    echo "A coordinator should give you this file."
    exit 1
fi
# Check if "download_url" and "upload_url" variables are set.
if [ -z "$download_url" ] || [ -z "$upload_url" ]; then
    echo "download_url and upload_url must be set in $env_file"
    exit 1
fi

# Check if gnark-phase2-mpc-wrapper executable exists
# Pull and build if not so
if [ ! -f "gnark-phase2-mpc-wrapper-executable" ]; then
    echo ""
    echo "Cloning and building gnark-phase2-mpc-wrapper"
    git clone https://github.com/irfanbozkurt/gnark-phase2-mpc-wrapper.git
    cd gnark-phase2-mpc-wrapper
    go mod tidy
    go build
    cd ..
    mv gnark-phase2-mpc-wrapper/gnark-phase2-mpc-wrapper gnark-phase2-mpc-wrapper-executable
    rm -rf gnark-phase2-mpc-wrapper
fi

# Download the latest contribution from S3
echo ""
echo "Downloading previous contribution"
curl -O $download_url

# Prepare the filenames
url_basename=$(basename $download_url)
previous_contribution_file_name=$(echo $url_basename | cut -d'?' -f 1)
previous_contribution_number=$(echo $previous_contribution_file_name | cut -d'_' -f 2 | cut -d'.' -f 1)
current_contribution_number=$((previous_contribution_number + 1))
current_contribution_file_name=$(echo $previous_contribution_file_name | sed "s/_${previous_contribution_number}\./_${current_contribution_number}\./")

# Perform the contribution
echo ""
echo "Performing the contribution"
./gnark-phase2-mpc-wrapper-executable p2c $previous_contribution_file_name $current_contribution_file_name

# Upload the contribution to S3
curl -v -T $current_contribution_file_name $upload_url

rm $previous_contribution_file_name
rm $current_contribution_file_name
rm gnark-phase2-mpc-wrapper-executable

echo "The contribution has completed successfully! Thank you for participating in the ceremony!"
