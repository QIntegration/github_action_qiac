# Container image that runs your code
FROM alpine:3.14.2

COPY entrypoint.sh /entrypoint.sh
COPY resultParser.py /resultParser.py

ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
RUN apk add --no-cache --virtual .pynacl_deps build-base python3-dev libffi-dev
RUN pip3 install Qualys-IaC-Security
RUN apk add git

RUN ["chmod", "+x", "/entrypoint.sh"]

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["sh","/entrypoint.sh"]
