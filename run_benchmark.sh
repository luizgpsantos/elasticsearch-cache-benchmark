set -x

exec > >(tee "$HOME/benchmark_$(date +"%Y_%m_%d_%I_%M_%p").log") 2>&1

while getopts h:p:w:t: flag
do
    case "${flag}" in
        h) monitoringhost=${OPTARG};;
        p) monitoringport=${OPTARG};;
        w) monitoringpw=${OPTARG};;
        t) track=${OPTARG};;
    esac
done

clear_cache_wait () {
    curl -s -X POST "localhost:39200/_cache/clear?pretty"
    sleep 2m
}

race () {
    RACE_ID=$(uuidgen)
    esrally race --pipeline=benchmark-only --target-host=127.0.0.1:39200 --track-path=$track --client-options="timeout:60" --challenge=$1 --kill-running-processes --on-error=abort --race-id=$RACE_ID
    clear_cache_wait
    echo $RACE_ID
}

export CLUSTER_NAME="rally-benchmark_$(date +"%Y%m%d%H%M%S")"
export MONITORING_HOST=$monitoringhost
export MONITORING_PORT=$monitoringport
export MONITORING_PASSWORD=$monitoringpw

sed -e 's|CLUSTER_NAME|'$CLUSTER_NAME'|' -e 's|MONITORING_HOST|'$MONITORING_HOST'|' -e 's|MONITORING_PORT|'$MONITORING_PORT'|' -e 's|MONITORING_PASSWORD|'$MONITORING_PASSWORD'|' car_params.json | tee car_params_concrete.json

INSTALLATION_ID=`esrally install --quiet --distribution-version=7.12.0 --node-name="rally-node-0" --network-host="127.0.0.1" --http-port=39200 --master-nodes="rally-node-0" --seed-hosts="127.0.0.1:39300" --car="4gheap,x-pack-monitoring-http" --car-params=car_params_concrete.json | jq --raw-output '.["installation-id"]'`

esrally start --installation-id="${INSTALLATION_ID}" --race-id="${RACE_ID}"

aggregations_without_cache=$(race "aggregations_without_cache")
aggregations_with_cache=$(race "aggregations_with_cache")
random-product-search-without-cache=$(race "random-product-search-without-cache")
random-product-search-with-cache=$(race "random-product-search-with-cache")
random-filtered-product-search-without-cache=$(race "random-filtered-product-search-without-cache")
random-filtered-product-search-with-cache=$(race "random-filtered-product-search-with-cache")

esrally stop --installation-id="${INSTALLATION_ID}"

echo "esrally compare --baseline=$aggregations_without_cache --contender=$aggregations_with_cache"
echo "esrally compare --baseline=${random-product-search-without-cache} --contender=${random-product-search-with-cache}"
echo "esrally compare --baseline=${random-filtered-product-search-without-cache} --contender=${random-filtered-product-search-with-cache}"