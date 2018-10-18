#!/bin/bash

HOST="${1:-http://localhost:3000}"
GRAFANA_API_KEY=YOUR_KEY

EXPORT_DIR=${EXPORT_DIR:-dashboards}

mkdir -p $EXPORT_DIR

for dash in $(curl -s -k -H "Authorization: Bearer $GRAFANA_API_KEY" $HOST/api/search\?query\=\& | jq -r ".[].uri" ); do
  filename=`echo $dash.json | cut -c 4-`
  echo "export $filename"
  curl -s -k -H "Authorization: Bearer $GRAFANA_API_KEY" $HOST/api/dashboards/$dash | jq ".dashboard " > ${EXPORT_DIR}/$filename
done
