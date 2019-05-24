#10000,2,2500
#10000,2,4722


{
cat <<EOF
10000,2,7500
EOF
} |
    sed -e 's+\([0-9]*\),\([0-9]*\),\([0-9]*\)+--ratelimit=\1k --flows=\2 --netem="rate \3kbit" --outdir=/ymslanda/bandwidthestimator/data/\1,\2,\3+g' |
    parallel --line-buffer -S "$CLUSTER_NODES" 'cd /ymslanda/bandwidthestimator/PassiveBandwidthEstimator; ./trafficsimulator.sh --control=/ymslanda/bandwidthestimator/control/$(hostname) {}'
