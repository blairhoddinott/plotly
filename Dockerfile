FROM python:3.8.17-alpine AS base
WORKDIR /srv/userapi
COPY src/requirements.txt .

FROM base as requirements
RUN apk add python3-dev build-base linux-headers pcre-dev libffi-dev
RUN pip install --upgrade pip
RUN pip install --no-cache-dir --upgrade -r requirements.txt
RUN pip install gunicorn

FROM requirements AS app
COPY src/ .
CMD ["gunicorn", "--conf", "gunicorn_conf.py", "--bind", "0.0.0.0:80", "userapi:app"]