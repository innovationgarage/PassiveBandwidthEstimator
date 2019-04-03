#! /bin/bash

default () {
    if ! [ "$(eval "echo \"\$$1\"")" ]; then
        eval "export $1='$2'"
    fi
}

default ARG_control ./control

default ARG_outdir .

default ARG_client client.sh
default ARG_server server.sh

default ARG_flows 5
default ARG_ratelimit 10M

default ARG_netem "rate 100kbit"

default ARG_time 60s

argparse() {
   export ARGS=()
   for _ARG in "$@"; do
       if [ "${_ARG##--*}" == "" ]; then
           _ARG="${_ARG#--}"
           if [ "${_ARG%%*=*}" == "" ]; then
               _ARGNAME="$(echo ${_ARG%=*} | tr -_ )"
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

trafficsimulator.sh OPTIONS

  --client=./client.sh
  --server=./server.sh
  --flows=$ARG_flows
  --ratelimit=$ARG_ratelimit
  --netem="$ARG_netem"

  --time=$ARG_time

  --control=$ARG_control
  --outdir=$ARG_outdir

Any OPTIONS can also be given as environment variables with their
names prefixed with ARG_, e.g.

  export ARG_ratelimit=$ARG_ratelimit
EOF
    exit 1
fi

echo "Settings:"
export | grep ARG_
echo

mkdir -p control/{h1,h2}
cp $ARG_client control/h1/script2
cp $ARG_server control/h2/script2

cat > control/h1/script <<EOF
#! /bin/bash
set -x

$(export | grep ARG_)

/control/script2
EOF

cat > control/h2/script <<EOF
#! /bin/bash
set -x

$(export | grep ARG_)

/control/script2
EOF

chmod ugo+rx control/*/script*

docker-compose -f trafficsimulator-compose.yml up --abort-on-container-exit

mkdir -p $ARG_outdir
mv control/h1/dumpfile* $ARG_outdir
