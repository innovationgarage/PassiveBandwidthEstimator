#! /bin/bash

source VERSION

REPOSITORY="$1"
ROOT="$2"
NAME="$(echo "$3" | tr ",." "__")"
ARGS="$(echo "$3" | sed -e "s+\([0-9.]*\),\([0-9.]*\),\([0-9.]*\)+--name=\"ts_${NAME}\" --control=\"$ROOT/control/$(hostname)-\1,\2,\3\" --ratelimit=\1k --flows=\2 --netem=\"rate \3kbit;5C\" --outdir=\"$ROOT/data/\1,\2,\3\"+g")"

echo "GRIDSEARCH STEP @ $(hostname): ./trafficsimulator.sh $ARGS"

if [ "$(docker image ls -q "${ARG_repository}traffic-simulator:${VERSION}")" == "" ]; then
  docker pull "${REPOSITORY}traffic-simulator:${VERSION}"
fi

eval "./trafficsimulator.sh --repository='${REPOSITORY}' $ARGS"

echo "GRIDSEARCH STEP DONE @ $(hostname): ./trafficsimulator.sh $ARGS"
