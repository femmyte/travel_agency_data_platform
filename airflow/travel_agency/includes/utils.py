
from boto3 import Session


def aws_sesion():
    session = Session(
        aws_access_key_id="YourAccessKey",
        aws_secret_access_key="YourSecretKey",
        region_name="eu-central-1"
    )

    return session
