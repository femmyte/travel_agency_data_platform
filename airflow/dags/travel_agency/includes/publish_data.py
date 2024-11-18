from travel_agency.includes.utils import aws_session, get_country_data, logging
import awswrangler as wr


# Storing data on Data Lake
def store_data_on_lake(dir, data=None):
    if data is None:
        DataFrame = get_country_data()
    else:
        DataFrame = data
    wr.s3.to_parquet(
        df=DataFrame,
        path=f"s3://travel-agency-bucket/{dir}",
        boto3_session=aws_session(),
        mode="overwrite",
        dataset=True
    )
    logging.info(f"Data stored on {dir} S3 successfully")
    return "Data stored on S3 successfully"


# logging.info(store_data_on_lake())
