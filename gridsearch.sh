#! /bin/bash
set -e

default () {
    if ! [ "$(eval "echo \"\$$1\"")" ]; then
        eval "export $1='$2'"
    fi
}

default ARG_outdir ../

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

Any OPTIONS can also be given as environment variables with their
names prefixed with ARG_, e.g.

  export ARG_outdir=${ARG_outdir}
EOF
    exit 1
fi

ROOT="$(pwd)"

{
cat <<EOF
10000,2,2500
10000,2,4722
10000,2,7500
EOF
} |
  parallel --will-cite -S "$CLUSTER_NODES" --line-buffer "cd '${ROOT}'; ./gridsearchtask.sh '${ARG_outdir}' {}"
