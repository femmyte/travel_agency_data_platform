
from boto3 import Session
import requests
import pandas as pd
import logging
import os
from dotenv import load_dotenv
load_dotenv()

# setting log level for debugging purpose
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s:%(name)s:%(message)s'
)


def aws_session():
    session = Session(
        aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
        aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
        region_name="us-east-1"
    )

    return session


url = "https://restcountries.com/v3.1/all"


def get_country_data():
    response = requests.get(url)
    response_json = response.json()

    data = pd.DataFrame(response_json)
    return data
