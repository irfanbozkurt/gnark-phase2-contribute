#!/bin/bash

bucket_name="assets.lighter.xyz"
ptau_file="10.ptau"
phase2Evaluations="phase2Evaluations"
r1cs_file="test.r1cs"

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

# Check the ph2 file
# This input can be an integer or a file path. Download if it's an integer. 
if [ -z "$1" ]; then
    echo "Error: Last contribution must be provided as the first argument"
    exit 1
fi
latest_contribution="$1"
if [[ $latest_contribution =~ ^[0-9]+$ ]]; then
    echo "Downloading corresponding contribution file from the bucket"
    latest_contribution="contribution_$1.ph2"
    aws s3 cp s3://assets.lighter.xyz/$latest_contribution $latest_contribution
    echo ""
fi
if [ ! -f "$latest_contribution" ]; then
    echo "Error: The file '$latest_contribution' does not exist"
    exit 1
fi

aws s3 cp s3://$bucket_name/$ptau_file $ptau_file
aws s3 cp s3://$bucket_name/$r1cs_file $r1cs_file
aws s3 cp s3://$bucket_name/$phase2Evaluations $phase2Evaluations

# Check the ptau file
if [ ! -f "$ptau_file" ]; then
    echo "Error: The file '$ptau_file' does not exist"
    exit 1
fi
# Check the phase2Evaluations file
if [ ! -f "$phase2Evaluations" ]; then
    echo "Error: The file '$phase2Evaluations' does not exist"
    exit 1
fi
# Check the r1cs file
if [ ! -f "$r1cs_file" ]; then
    echo "Error: The file '$r1cs_file' does not exist"
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

# Extract pkey and vkey
echo "Extracting pkey and vkey"
./gnark-phase2-mpc-wrapper-executable extract-keys $ptau_file $latest_contribution $phase2Evaluations $r1cs_file
echo ""

rm $ptau_file
rm $latest_contribution
rm $phase2Evaluations
rm $r1cs_file
rm gnark-phase2-mpc-wrapper-executable
