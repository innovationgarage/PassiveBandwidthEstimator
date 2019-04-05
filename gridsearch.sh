{
cat <<EOF
10000,2,2500
10000,2,4722
10000,2,7500
EOF
} |
  parallel -S "$CLUSTER_NODES" --line-buffer 'cd /ymslanda/bandwidthestimator/PassiveBandwidthEstimator; ./gridsearchtask.sh /ymslanda/bandwidthestimator {}'
