#! /bin/bash

source VERSION

REPOSITORY="$1"
ROOT="$2"

NAME="$(echo "$3" | tr ",." "__")"

DIRPREFIX="$(echo "$3" | sed -e "s+,++g" -e "s+\(.\)+\1/+g" -e "s+/$++g")"

read LINKBW FLOWS FLOWBW FLOWBW0 < <(echo "$3" | tr "," " ")

CONTROL="${ROOT}/control/$(hostname)-${LINKBW},${FLOWS},${FLOWBW},${FLOWBW0}"
OUTDIR="$ROOT/data/${DIRPREFIX}/${LINKBW},${FLOWS},${FLOWBW},${FLOWBW0}"

ARGS="--name=\"ts_${NAME}\" --control=\"${CONTROL}\" --ratelimit0=${FLOWBW0}k --ratelimit=${FLOWBW}k --flows=${FLOWS} --netem=\"rate ${LINKBW}kbit\" --outdir=\"${OUTDIR}\""

echo "GRIDSEARCH STEP @ $(hostname): ./trafficsimulator.sh $ARGS"

if [ "$(docker image ls -q "${ARG_repository}traffic-simulator:${VERSION}")" == "" ]; then
  docker pull "${REPOSITORY}traffic-simulator:${VERSION}"
fi

docker network prune -f
docker container prune -f

eval "./trafficsimulator.sh --repository='${REPOSITORY}' $ARGS"

rm -rf "${CONTROL}"
echo "GRIDSEARCH STEP DONE @ $(hostname): ./trafficsimulator.sh $ARGS"
