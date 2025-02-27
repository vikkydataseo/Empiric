# Dockerfile for publisher
FROM python:3.9.14-slim-buster AS base

# Needed for fastecdsa
RUN apt-get update && apt-get install -y gcc python-dev libgmp3-dev
RUN python -m pip install --upgrade pip

COPY requirements.txt /requirements.txt
RUN pip install -r requirements.txt --upgrade --upgrade-strategy eager

FROM base as test
COPY empiric-package/ /empiric-package
RUN pip install -e empiric-package/

FROM base as production
ARG EMPIRIC_PACKAGE_VERSION
RUN pip install empiric-network==$EMPIRIC_PACKAGE_VERSION
