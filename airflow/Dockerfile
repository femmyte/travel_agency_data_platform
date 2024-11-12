FROM python:3.9

WORKDIR /usr/local/airflow

# add folder to destination
ADD ./dags/travel_agency/includes ./includes

# install dependencies
RUN pip install requests awswrangler python-dotenv

# Keep the container running
CMD ["tail", "-f", "/dev/null"]