FROM python:3.7-alpine AS builder

RUN apk --update add --no-cache \
    g++ && \
    pip install --no-cache-dir \
    grpcio-tools

RUN cd /tmp && \
    wget https://github.com/mumble-voip/mumble/releases/download/1.2.19/mumble-1.2.19.tar.gz && \
    tar xzf mumble-1.2.19.tar.gz && \
    cd mumble-1.2.19/src && \
    sed -i '1isyntax = "proto2";' Mumble.proto && \
    python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. Mumble.proto


FROM python:3.7-alpine

WORKDIR /eve-bot

COPY --from=builder /tmp/mumble-1.2.19/src/Mumble_pb2.py ./

RUN apk --update add --no-cache \
    bash

RUN pip install --no-cache-dir \
    protobuf==3.8.0



COPY eve-bot.py ./

ENV MUMBLE_PORT 64738
ENV DELAY 90
ENV BOT_NICKNAME "-Eve-"
ENV MIMIC_PREFIX "Mimic-"
ENV MIMIC_VERSION "1.2.19"

CMD python -u ./eve-bot.py --eavesdrop-in="$EAVESDROP_IN" --relay-to="$RELAY_TO" --server=$MUMBLE_SERVER --delay=$DELAY --nick=$BOT_NICKNAME --mimic-prefix=$MIMIC_PREFIX --mimic-version=$MIMIC_VERSION