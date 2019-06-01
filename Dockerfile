ARG PYTHON_VER=3.7
ARG PROTOBUF_VER=3.8.0
ARG MUMBLE_VER=1.2.19

FROM python:${PYTHON_VER}-alpine AS builder

ARG PROTOBUF_VER
ARG MUMBLE_VER

RUN apk --update add --no-cache \
    libtool \
    make \
    g++

RUN cd /tmp && \
    wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VER}/protobuf-all-${PROTOBUF_VER}.tar.gz && \
    tar xzf protobuf-all-${PROTOBUF_VER}.tar.gz && \
    cd protobuf-${PROTOBUF_VER} && \
    ./configure && \
    make && \
    make check && \
    make install

RUN cd /tmp && \
    wget https://github.com/mumble-voip/mumble/releases/download/${MUMBLE_VER}/mumble-${MUMBLE_VER}.tar.gz && \
    tar xzf mumble-${MUMBLE_VER}.tar.gz && \
    cd mumble-${MUMBLE_VER}/src && \
    sed -i '1isyntax = "proto2";' Mumble.proto && \
    protoc --python_out=. Mumble.proto


FROM python:${PYTHON_VER}-alpine

ARG PROTOBUF_VER
ARG MUMBLE_VER

RUN apk --update add --no-cache bash && \
    pip install --no-cache-dir protobuf==${PROTOBUF_VER}

WORKDIR /eve-bot

COPY --from=builder /tmp/mumble-${MUMBLE_VER}/src/Mumble_pb2.py ./
COPY eve-bot.py ./

ENV MUMBLE_PORT 64738
ENV DELAY 90
ENV BOT_NICKNAME "-Eve-"
ENV MIMIC_PREFIX "Mimic-"
ENV MIMIC_VERSION ${MUMBLE_VER}

CMD python -u ./eve-bot.py --eavesdrop-in="$EAVESDROP_IN" --relay-to="$RELAY_TO" --server=$MUMBLE_SERVER --delay=$DELAY --nick=$BOT_NICKNAME --mimic-prefix=$MIMIC_PREFIX --mimic-version=$MIMIC_VERSION