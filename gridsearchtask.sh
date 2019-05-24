#! /bin/bash

ROOT="$1"
ARGS="$(echo "$2" | sed -e 's+\([0-9]*\),\([0-9]*\),\([0-9]*\)+--control="$ROOT/control/$(hostname)" --ratelimit=\1k --flows=\2 --netem="rate \3kbit" --outdir=$ROOT/data/\1,\2,\3+g')"

eval "./trafficsimulator.sh $ARGS"
