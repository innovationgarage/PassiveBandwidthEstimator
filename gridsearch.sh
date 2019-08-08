#! /bin/bash
set -e

source VERSION

default () {
    if ! [ "$(eval "echo \"\$$1\"")" ]; then
        eval "export $1='$2'"
    fi
}

default ARG_outdir ..

argparse() {
   export ARGS=()
   for _ARG in "$@"; do
       if [ "${_ARG##--*}" == "" ]; then
           _ARG="${_ARG#--}"
           if [ "${_ARG%%*=*}" == "" ]; then
               _ARGNAME="$(echo ${_ARG%=*} | tr - _)"
               eval "export ARG_${_ARGNAME}"='"${_ARG#*=}"'
           else
               eval "export ARG_${_ARG}"='True'
           fi
       else
           ARGS+=($_ARG)
       fi
   done
}

argparse "$@"

if [ "$ARG_help" ]; then
    cat <<EOF
Usage:

gridsearch.sh OPTIONS

    --outdir=${ARG_outdir}
    --repository=${ARG_repository}

    All options accepted by generategrid.py, e.g.:

    --flows-min=2
    --flows-max=40

    --link-min=100
      Link minimum bandwidth is in kbit.
    --link-max=10000
      Link maximum bandwidth is in kbit.
    --link-resolution=20
      Number of different link bandwidths to generate

    --flow-bw-min=0.5
    --flow-bw-max=1.5
      Range of cross traffic flow bandwidth to generate. Fraction of link bandwidth: 0.5 means 0.5*linkbw
    --flow-bw-resolution=10
      Number of different cross traffic flow bandwidths to generate.

    --flow-bw0-min=0.5
    --flow-bw0-max=1.5
      Range of flow bandwidth to generate. Fraction of link bandwidth: 0.5 means from 0.5*linkbw
    --flow-bw0-resolution=10
      Number of different flow bandwidths to generate.

Any OPTIONS can also be given as environment variables with their
names prefixed with ARG_, e.g.

  export ARG_outdir=${ARG_outdir}
EOF
    exit 1
fi

ROOT="$(pwd)"

if [ "$(docker image ls -q "${ARG_repository}traffic-simulator:${VERSION}")" == "" ]; then
  docker build --tag "${ARG_repository}traffic-simulator:${VERSION}" host
  docker push "${ARG_repository}traffic-simulator:${VERSION}"
fi

./generategrid.py |
  parallel --will-cite -S "$CLUSTER_NODES" --line-buffer "cd '${ROOT}'; ./gridsearchtask.sh '${ARG_repository}' '${ARG_outdir}' {}"
