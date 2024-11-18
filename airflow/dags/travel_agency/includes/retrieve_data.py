import awswrangler as wr
from travel_agency.includes.utils import aws_session, logging
from travel_agency.includes.publish_data import store_data_on_lake
from datetime import datetime
import pandas as pd


def retrieve_and_process_data():
    # Retrieve data from the Parquet file in S3
    df = wr.s3.read_parquet(
        path="s3://travel-agency-bucket/raw_data/",
        dataset=True,
        boto3_session=aws_session(),
    )

    # Process and transform the necessary data
    data = transform_data(df)
    logging.info("Data transformed successfully")
    if data is not None:
        store_data_on_lake("processed_data", data=data)
    return data


def extract_single_value(column):
    return column.apply(
        lambda x: x[0] if hasattr(x, '__getitem__') and len(x) > 0 else None
    )


def transform_data(df):
    # Flatten the DataFrame except for deeply nested structures
    df_flat = pd.json_normalize(df.to_dict(orient='records'))

    # Columns of interest
    columns_of_interest = [
        "name.common", "name.official", 'name', "independent",
        "unMember", "startOfWeek", "currencies", "capital",
        "region", "subregion", "languages", "area", "population",
        "continents", "idd.root", "idd.suffixes"
    ]
    flat_data = df_flat.loc[:, [
        col for col in columns_of_interest if col in df_flat.columns]]
    # extract common native names
    common_native_names_df = extract_all_common_native_names(df)
    # Process the 'currencies' column
    currencies_df = extract_currency_details(flat_data, df)

    # Extract single values from list-type columns
    for col in ['continents', 'idd.suffixes', 'capital']:
        if col in flat_data.columns:
            flat_data[col] = extract_single_value(flat_data[col])

    # Process the 'languages' column (which contains language codes and names)
    languages_df = extract_languages(flat_data, df)
    # Combine all processed data
    flat_data = flat_data.reset_index(drop=True)
    result = pd.concat(
        [flat_data, pd.DataFrame([{}] * len(flat_data))], axis=1)

    result = result.join(currencies_df).join(
        languages_df).join(common_native_names_df)

    # result = result.join(currencies_df).join(
    #     languages_df)

    # concatenate the idd root and suffixes
    result['country_code'] = result['idd.root'] + ' ' + result['idd.suffixes']

    # rename column for easy access in the table
    result = result.rename(columns={
        'name.common': 'country_name',
        'name.official': 'official_name', 'unMember': 'un_member',
        'startOfWeek': 'start_of_week'})
    # df = df.rename(columns={'name.official': 'officialname'})
    result = result.drop(
        columns=['languages', 'currencies', 'idd.root', 'idd.suffixes'])
    # order columns in the right order
    # desired_order = [
    #     'country_name', 'independent', 'un_member', 'start_of_week',
    #     'official_name',
    #     'currency_code', 'currency_name', 'currency_symbol',
    #     'country_code', 'capital', 'region', 'subregion',
    #     'language', 'area', 'population', 'continents'
    # ]
    # result = result[desired_order]
    result.to_csv('EXTRACT.csv', index=False)
    logging.info(result.head())
    return result


def extract_currency_details(flat_data, df):
    if 'currencies' in flat_data.columns:
        # Access directly from the original DataFrame
        currencies = df['currencies'].dropna()
        selected_currencies = []

        for currency_dict in currencies:
            if isinstance(currency_dict, dict):
                for code, details in currency_dict.items():
                    if (isinstance(details, dict) and
                            details.get("symbol") is not None):
                        selected_currencies.append({
                            "currency_code": code,
                            "currency_name": details.get("name"),
                            "currency_symbol": details.get("symbol")
                        })

        currencies_df = pd.DataFrame(selected_currencies)
    else:
        currencies_df = pd.DataFrame(
            columns=["currency_code", "currency_name", "currency_symbol"])
    return currencies_df


def extract_all_common_native_names(df):
    if 'name' in df.columns:
        names = df['name']
        selected_name = []
        for data in names:
            native_names = data.get('nativeName', {})
            # Drop rows with NaN in column
            native_names = df['name'].dropna()
            for i, details in native_names.items():
                if details and isinstance(details, dict) and 'common' in details:
                    selected_name.append({
                        "common_native_names": details['common']
                    })
        native_names_df = pd.DataFrame(selected_name)
    else:
        native_names_df = pd.DataFrame(columns=["common_native_names"])
    return native_names_df


def extract_languages(flat_data, df):
    if 'languages' in flat_data.columns:
        # Drop rows with NaN in 'languages' column
        languages = df['languages'].dropna()
        selected_languages = []

        for lang_dict in languages:
            if isinstance(lang_dict, dict):
                for lang_code, lang_name in lang_dict.items():
                    if lang_name:  # Only include languages where the name is not None
                        selected_languages.append({
                            "language": lang_name
                        })

        languages_df = pd.DataFrame(selected_languages)
    else:
        languages_df = pd.DataFrame(columns=["language"])
    return languages_df
