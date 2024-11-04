FROM python:3.11-slim-bullseye as builder

WORKDIR /app

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

RUN apt-get update && apt-get install --no-install-recommends -y build-essential libssl-dev libffi-dev libyaml-dev git && python -m pip install --upgrade pip

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim-bullseye

ENV EZBEQ_CONFIG_HOME=/config

COPY --from=builder /opt/venv /opt/venv

WORKDIR /app
VOLUME ["/config"]

ENV PATH="/opt/venv/bin:${PATH}"

RUN apt-get update && apt-get install --no-install-recommends -y curl && apt-get install --no-install-recommends -y sqlite3

ADD https://github.com/mrene/minidsp-rs/releases/download/v0.1.12/minidsp_0.1.12-1_amd64.deb

RUN apt-get install -y ./minidsp_0.1.12-1_amd64.deb

HEALTHCHECK --interval=10s --timeout=2s \
  CMD curl -f -s --show-error http://localhost:8080/api/1/version || exit 1

EXPOSE 8080

CMD [ "ezbeq" ]

