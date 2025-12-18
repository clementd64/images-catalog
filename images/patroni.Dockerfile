FROM postgres:alpine AS base

RUN apk add --no-cache python3
ENV VIRTUAL_ENV=/opt/patroni
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

FROM base AS build

RUN apk add --no-cache build-base linux-headers python3-dev py3-pip && python3 -m venv /opt/patroni
RUN pip install patroni[etcd3,psycopg3]

FROM base

COPY --from=build /opt/patroni /opt/patroni

USER postgres
ENTRYPOINT [ "patroni" ]
