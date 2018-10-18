docker run \
  -d \
  -p 3000:3000 \
  -v ~/var/grafana2:/var/lib/grafana \
  --name grafana-finc \
  grafana/grafana
