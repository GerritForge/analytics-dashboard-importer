# analytics-dashboard-importer
Dashboard importer of the Kibana dashboards for Gerrit Analytics

# Notes

If you need to regenerate kibana's configurations (i.e.: index pattern, visualizations, etc) you'll need to install [elasticdump](https://www.npmjs.com/package/elasticdump)

## Update index pattern

If you need to regenerate kibana's index pattern (tipically if you are now extracting an additional field into elasticsearch),
you'll need to dump your kibana's index pattern as follows (this example is for gitcommits):

```bash
elasticdump --input='http://<elasitc_search_host>:9200/.kibana' --output=$ --type=data --searchBody '{"query":{"term":{"_id": "gitcommits"}}}' | jq .
```
- Save the output into **kibana-config/settings/base/2_index-pattern.gitcommits.data.json** file

## Update dashboard

```bash
elasticdump --input='http://<elasitc_search_host>:9200/.kibana' --output=$ --type=data \
  | jq -c 'select(._type == "dashboard")' \
  | jq . > kibana-config/4_dashboard_projects.kibana.data.json
```

## Add or update a visualization

An example that shows how to add/update the `Overall statistics` visualization:

```bash
elasticdump --input='http://localhost:9200/.kibana' --output=$ --type=data \
| jq -c 'select(._type == "visualization") | select(._source.title == "Overall statistics")' \
| jq . >  kibana-config/3_visualization_overall-statistics.kibana.data.json
```

