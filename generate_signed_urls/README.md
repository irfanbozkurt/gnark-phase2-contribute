This is for the coordinator and has nothing to do with contributors.

## Prerequisites

- Python3
- boto3
- aws configure
- Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY env variables

Replace the `bucket_name` variable with the name of the S3 bucket where you want to store the files.

```bash
python script.py total_contributor_count;
```

This will output `total_contributor_count` .env files each with a signed URL that will be used by the link holder to upload their contribution with name contribution\_<span style="color:red">contributor_number</span>.ph2
