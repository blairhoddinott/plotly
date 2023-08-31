FROM python:3.8.17 AS base
WORKDIR /srv/userapi
COPY src/requirements.txt .

FROM base as requirements
RUN ls -al
RUN pip install -r requirements.txt

FROM requirements AS app
COPY src/ .
CMD ["flask", "run"]