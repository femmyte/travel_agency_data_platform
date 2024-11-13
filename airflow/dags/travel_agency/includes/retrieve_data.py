import awswrangler as wr
from travel_agency.includes.utils import aws_session, logging
from travel_agency.includes.publish_data import store_data_on_lake


def retrieve_and_process_data():
    # Retrieve data from the Parquet file in S3
    df = wr.s3.read_parquet(
        path="s3://travel-agency-bucket/raw_data/",
        dataset=True,
        boto3_session=aws_session(),
    )

    # Process and transform the necessary data
    columns_of_interest = (
        ["name", "independent", "unMember", "startOfWeek",
         "currencies", "idd", "capital", "region", "subregion",
         "languages", "area", "population", "continents"])
    data = df.loc[:, columns_of_interest]
    logging.info("Data retrieved successfully")
    data = transform_data(data)
    logging.info("Data transformed successfully")
    if data is not None:
        store_data_on_lake("processed_data", data=data)
    return data


def transform_data(data):
    # Extracting common and official name from the 'name' field
    data['common_name'] = data['name'].apply(
        lambda x: x.get('common') if isinstance(x, dict) else None)
    data['official_name'] = data['name'].apply(
        lambda x: x.get('official') if isinstance(x, dict) else None)

    # Safely extracting the currency_code dynamically
    # from the 'currencies' field
    # assuming that each country has one currency,
    # and extract the currency code from the key in 'currencies'
    data['currency_code'] = (
        data['currencies'].apply(
            lambda x: ', '.join([k for k, v in x.items()
                                 if v is not None]) if isinstance(
                x, dict) and x else None
        ))
    # Get currency name
    data['currency_name'] = data['currencies'].apply(
        lambda x: next((v['name']
                       for k, v in x.items() if v is not None), None)
        if isinstance(x, dict) else None
    )

    # Get currency symbol
    data['currency_symbol'] = data['currencies'].apply(
        lambda x: next((v['symbol']
                       for k, v in x.items() if v is not None), None)
        if isinstance(x, dict) else None
    )

    # Handling 'idd' safely (concatenating root and suffixes)
    data['idd'] = (
        data['idd'].apply(lambda x: f"{x.get('root', '')}{
            ''.join(x.get('suffixes', []))}"
            if isinstance(x, dict) and x.get('root') else None))

    # Extracting region and subregion
    data['region'] = data['region'].apply(
        lambda x: x if isinstance(x, str) else None)
    data['subregion'] = data['subregion'].apply(
        lambda x: x if isinstance(x, str) else None)

    # Extracting languages
    data['languages'] = data['languages'].apply(
        lambda x: [v for k, v in x.items() if v is not None] if isinstance(
            x, dict) and x else None
    )
    # Extracting continents
    data['continents'] = data['continents'].apply(lambda x: x[0])
    # delete unnecessary columns
    data = data.drop(columns=['name', 'currencies'])
    data.to_csv('transformed_data.csv', index=False)
    return data
