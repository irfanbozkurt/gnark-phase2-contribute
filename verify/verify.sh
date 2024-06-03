#!/bin/bash

bucket_name="mpc-ceremony"

# Check if Go is installed
if ! command -v go &>/dev/null; then
   echo "Go is not installed."
   echo "Please install Go and try again."
   exit 1
fi

# Check if git is installed
if ! git --version 2>&1 >/dev/null ; then 
   echo "Git is not installed."
   echo "Please install Git and try again."
   exit 1
fi

# Check provided contribution number
if ! [[ "$1" =~ ^[0-9]+$ ]] && (( $1 > 0 )); then
    echo "Error: Contribution number must be an integer > 0"
    echo "You provided: $1"
    exit 1
fi

# Build the file names
contribution_to_verify="contribution_$1.ph2"
minus_one=$(($1 - 1))
previous_contribution="contribution_$minus_one.ph2"

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

# Download the two contributions
echo "Downloading the artifacts..."
aws s3 --endpoint-url http://localhost:4566 cp s3://$bucket_name/$previous_contribution $previous_contribution
aws s3 --endpoint-url http://localhost:4566 cp s3://$bucket_name/$contribution_to_verify $contribution_to_verify
# echo ""

# Verify
echo "Verifying the contribution"
./gnark-phase2-mpc-wrapper-executable p2v $contribution_to_verify $previous_contribution
echo ""

rm $contribution_to_verify 
rm $previous_contribution
rm gnark-phase2-mpc-wrapper-executable
