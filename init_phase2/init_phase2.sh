#!/bin/bash

bucket_name="assets.lighter.xyz"

r1cs_file=$1
ptau_file=$2

if [ -z "$r1cs_file" ]; then
    echo "Error: No .r1cs file provided"
    exit 1
fi
if [ ! -f "$r1cs_file" ]; then
    echo "Error: File $r1cs_file does not exist"
    exit 1
fi

if [ -z "$ptau_file" ]; then
    echo "Error: No ptau file provided"
    exit 1
fi
if [ ! -f "$ptau_file" ]; then
    echo "Error: File $ptau_file does not exist"
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

echo "Initializing phase2 ceremony"
./gnark-phase2-mpc-wrapper-executable p2n $ptau_file $r1cs_file contribution_0.ph2
echo ""

echo "Uploading artifacts"
aws s3 cp $r1cs_file s3://$bucket_name/$r1cs_file
aws s3 cp $ptau_file s3://$bucket_name/$ptau_file
aws s3 cp phase2Evaluations s3://$bucket_name/phase2Evaluations
aws s3 cp contribution_0.ph2 s3://$bucket_name/contribution_0.ph2

rm gnark-phase2-mpc-wrapper-executable
rm contribution_0.ph2
rm phase2Evaluations
rm $r1cs_file
rm $ptau_file
