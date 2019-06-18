#! /bin/bash
set -e

source VERSION

default () {
    if ! [ "$(eval "echo \"\$$1\"")" ]; then
        eval "export $1='$2'"
    fi
}

default ARG_outdir ../pgaps
default ARG_indir ../data

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

gridpcaptotcpgaps.sh OPTIONS

    --indir=${ARG_indir}
    --outdir=${ARG_outdir}

Any OPTIONS can also be given as environment variables with their
names prefixed with ARG_, e.g.

  export ARG_outdir=${ARG_outdir}
EOF
    exit 1
fi

ROOT="$(pwd)"

echo "${ROOT}: ${ARG_indir} -> ${ARG_outdir}"

( cd ${ARG_indir}; find . -type f; ) |
  parallel --will-cite -S "$CLUSTER_NODES" --line-buffer "set -x; echo '{}'; cd '$ROOT'; source env/bin/activate; mkdir -p '${ARG_outdir}/{//}'; ./pcaptotcpgaps.py '${ARG_indir}/{}' '${ARG_outdir}/{}.npz'"
