FROM python:3.7-alpine

RUN apk --update add --no-cache bash tzdata

RUN pip install --no-cache-dir protobuf==3.7.1

WORKDIR /eve-bot

COPY Mumble_pb2.py ./
COPY eve-bot.py ./

ENV MUMBLE_PORT 64738
ENV DELAY 90
ENV BOT_NICKNAME "-Eve-"
ENV MIMIC_PREFIX "Mimic-"
ENV MIMIC_VERSION "1.2.19"

CMD python -u ./eve-bot.py --eavesdrop-in="$EAVESDROP_IN" --relay-to="$RELAY_TO" --server=$MUMBLE_SERVER --delay=$DELAY --nick=$BOT_NICKNAME --mimic-prefix=$MIMIC_PREFIX --mimic-version=$MIMIC_VERSION