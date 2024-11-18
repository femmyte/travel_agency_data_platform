from airflow import DAG
from datetime import datetime
from airflow.operators.python import PythonOperator
from travel_agency.includes.publish_data import store_data_on_lake
from travel_agency.includes.retrieve_data import (
    retrieve_and_process_data)
from airflow.providers.amazon.aws.operators.redshift_data import (
    RedshiftDataOperator)
from airflow.providers.amazon.aws.transfers.s3_to_redshift import (
    S3ToRedshiftOperator)

with DAG(
    dag_id='country_data_extraction',
    start_date=datetime(2023, 11, 9),
    schedule_interval='@daily',
    description="new updated",
    template_searchpath=(
        "/home/femmyte/Desktop/projects/CDE/travel_agency/airflow/"
        "dags/travel_agency/sql")
):

    download_data = PythonOperator(
        task_id='download_data',
        python_callable=store_data_on_lake,
        op_args=['raw_data']
    )

    retrieve_data = PythonOperator(
        task_id='retrieve_data',
        python_callable=retrieve_and_process_data
    )

    # create redshift table
    create_table_task = RedshiftDataOperator(
        task_id="create_agency_table",
        sql="/create_agency_table.sql",
        database='dev',
        cluster_identifier="travel-agency",
        db_user="femmyte",
        wait_for_completion=True,
        params={
            "schema": "public",
            "table": "country_info",
        },
    )
    # load transformed data from s3 bucket to Redshift
    s3_to_redshift = S3ToRedshiftOperator(
        task_id='s3_to_redshift',
        schema='public',
        table='country_info',
        s3_bucket='travel-agency-bucket',
        s3_key=(
            'processed_data/0854d86a2f33418fa7b0911f9f26b2a6.snappy.parquet'
        ),
        redshift_conn_id='redshift_default',
        aws_conn_id='aws_default',
        copy_options=[
            "FORMAT AS PARQUET"
        ],
        method='REPLACE',
    )


download_data >> retrieve_data >> create_table_task >> s3_to_redshift
