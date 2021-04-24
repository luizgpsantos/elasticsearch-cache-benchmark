while getopts u:a:f: flag
do
    case "${flag}" in
        t) track=${OPTARG};;
    esac
done

clear_cache_wait () {
    curl -X POST "localhost:39200/_cache/clear?pretty"
    sleep 2m
}

race () {
    esrally race --track-path=$track --client-options="timeout:60" --challenge=$1 --kill-running-processes
    clear_cache_wait
}

INSTALLATION_ID=`esrally install --quiet --distribution-version=7.12.0 --node-name="rally-node-0" --network-host="127.0.0.1" --http-port=39200 --master-nodes="rally-node-0" --seed-hosts="127.0.0.1:39300" --car="4gheap,x-pack-monitoring-http" --car-params=car_params.json | jq --raw-output '.["installation-id"]'`

export RACE_ID=$(uuidgen)
esrally start --installation-id="${INSTALLATION_ID}" --race-id="${RACE_ID}"

race "aggregations_without_cache"
race "aggregations_with_cache"
race "random-product-search-without-cache"
race "random-product-search-with-cache"
race "random-filtered-product-search-without-cache"
race "random-filtered-product-search-with-cache"

esrally stop --installation-id="${INSTALLATION_ID}"