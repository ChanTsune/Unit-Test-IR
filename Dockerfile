FROM python:3.7

RUN mkdir /env_create

COPY requirements.txt /env_create/requirements.txt

RUN pip install -r /env_create/requirements.txt

RUN mkdir /app

WORKDIR /app
