INSTALLATION_ID=`esrally install --quiet --distribution-version=7.12.0 --node-name="rally-node-0" --network-host="127.0.0.1" --http-port=39200 --master-nodes="rally-node-0" --seed-hosts="127.0.0.1:39300" | jq --raw-output '.["installation-id"]'`

export RACE_ID=$(uuidgen)
esrally start --installation-id="${INSTALLATION_ID}" --race-id="${RACE_ID}"