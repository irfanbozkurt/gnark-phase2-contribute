## Prerequisites

- [Go](https://golang.org/doc/install)
- git
- A configured AWS Cli
- Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY env variables

Script downloads the artifacts from the s3 bucket. Check the script for aws client configuration, and make sure it points to a valid bucket.

## Running the verification script

```bash
chmod +x verify.sh;
./verify.sh contribution_number
```

Where <span style="color:red">contribution_number</span> is an integer > 0 representing the contribution to be verified. This will download that contribution and the previous contribution, both of which are necessary for integrity verification.

Output is textual in the console.
