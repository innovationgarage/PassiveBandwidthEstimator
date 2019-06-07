#! /bin/bash
set -e

source VERSION

default () {
    if ! [ "$(eval "echo \"\$$1\"")" ]; then
        eval "export $1='$2'"
    fi
}

default ARG_name trafficsimulator

default ARG_control ./control

default ARG_outdir .

default ARG_client client.sh
default ARG_server server.sh

default ARG_flows 5
default ARG_ratelimit 10M

default ARG_netem "rate 100kbit"

default ARG_time 120s

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

trafficsimulator.sh OPTIONS

  --client=${ARG_client}
  --server=${ARG_server}
  --flows=${ARG_flows}
  --ratelimit=${ARG_ratelimit}
  --netem="${ARG_netem}"

  --time=${ARG_time}

  --control=${ARG_control}
  --outdir=${ARG_outdir}

  --repository=${ARG_repository}

  --name=${ARG_name}

Any OPTIONS can also be given as environment variables with their
names prefixed with ARG_, e.g.

  export ARG_ratelimit=${ARG_ratelimit}
EOF
    exit 1
fi

echo "Settings:"
export | grep ARG_
echo

mkdir -p "${ARG_control}"/{client,server}
cp $ARG_client "${ARG_control}/client/script2"
cp $ARG_server "${ARG_control}/server/script2"

cat > "${ARG_control}/client/script" <<EOF
#! /bin/bash
set -x

$(export | grep ARG_)

/control/script2
EOF

cat > "${ARG_control}/server/script" <<EOF
#! /bin/bash
set -x

$(export | grep ARG_)

/control/script2
EOF

chmod ugo+rx "${ARG_control}"/*/script*


if [ "$(docker image ls -q "${ARG_repository}traffic-simulator:${VERSION}")" == "" ]; then
  docker build --tag "${ARG_repository}traffic-simulator:${VERSION}" host
fi

docker-compose -p "${ARG_name}" -f trafficsimulator-compose.yml up --abort-on-container-exit

mkdir -p "${ARG_outdir}"
echo "${ARG_control}"/client/dumpfile*
ls "${ARG_control}"/client/dumpfile*
mv "${ARG_control}"/client/dumpfile* "${ARG_outdir}"
