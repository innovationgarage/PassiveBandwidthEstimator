#! /bin/bash

source VERSION

REPOSITORY="$1"
ROOT="$2"

NAME="$(echo "$3" | tr ",." "__")"

DIRPREFIX="$(echo "$3" | sed -e "s+,++g" -e "s+\(.\)+\1/+g" -e "s+/$++g")"

LINKBW="$(echo "$3" | sed -e "s+\([0-9.]*\),\([0-9.]*\),\([0-9.]*\)+\1+g")"
FLOWS="$(echo "$3" | sed -e "s+\([0-9.]*\),\([0-9.]*\),\([0-9.]*\)+\2+g")"
FLOWBW="$(echo "$3" | sed -e "s+\([0-9.]*\),\([0-9.]*\),\([0-9.]*\)+\3+g")"

CONTROL="${ROOT}/control/$(hostname)-${LINKBW},${FLOWS},${FLOWBW}"
OUTDIR="$ROOT/data/${DIRPREFIX}/${LINKBW},${FLOWS},${FLOWBW}"

ARGS="--name=\"ts_${NAME}\" --control=\"${CONTROL}\" --ratelimit=${FLOWBW}k --flows=${FLOWS} --netem=\"rate ${LINKBW}kbit\" --outdir=\"${OUTDIR}\""

echo "GRIDSEARCH STEP @ $(hostname): ./trafficsimulator.sh $ARGS"

if [ "$(docker image ls -q "${ARG_repository}traffic-simulator:${VERSION}")" == "" ]; then
  docker pull "${REPOSITORY}traffic-simulator:${VERSION}"
fi

docker network prune -f
docker container prune -f

eval "./trafficsimulator.sh --repository='${REPOSITORY}' $ARGS"

rm -rf "${CONTROL}"
echo "GRIDSEARCH STEP DONE @ $(hostname): ./trafficsimulator.sh $ARGS"
