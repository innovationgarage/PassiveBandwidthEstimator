#! /bin/bash

export ARG_client=client.sh
export ARG_server=server.sh

export ARG_flows=5
export ARG_ratelimit=10M

export ARG_netem="rate 100kbit"

export ARG_time=60s

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

run.sh OPTIONS

  --client=./client.sh
  --server=./server.sh
  --flows=$ARG_flows
  --ratelimit=$ARG_ratelimit
  --netem="$ARG_netem"

  --time=$ARG_time
EOF
    exit 1
fi

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

docker-compose up # -d

#sleep $ARG_time

#docker-compose down
