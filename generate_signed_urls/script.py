import argparse
import logging
import boto3

bucket_name = 'mpc-ceremony'

logger = logging.getLogger(__name__)
s3_client = boto3.client('s3', endpoint_url='http://localhost:4566')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'total_contributor_count', 
        type=int, 
        help="Expected contribution number as an integer."
    )
    args = parser.parse_args()

    current_contribution = 1
    for _ in range(args.total_contributor_count):

        prev_contribution = current_contribution - 1

        # Generate upload URL
        upload_url = s3_client.generate_presigned_url(
            ClientMethod='put_object',
            Params={
                'Bucket': bucket_name, 
                'Key': f"contribution_{current_contribution}.ph2"
            },
            ExpiresIn=86_400
        )

        # Generate download URL
        download_url = s3_client.generate_presigned_url(
            ClientMethod='get_object',
            Params={
                'Bucket': bucket_name, 
                'Key': f"contribution_{prev_contribution}.ph2"
            },
            ExpiresIn=86_400
        )

        with open(f"contribution_{current_contribution}.env", "w") as f:
            f.write(f"upload_url=\"{upload_url}\"\n")
            f.write(f"download_url=\"{download_url}\"\n")

        current_contribution += 1
