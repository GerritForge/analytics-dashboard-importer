# analytics-dashboard-importer
Dashboard importer of the Kibana dashboards for Gerrit Analytics

# Notes

## Update index pattern

If you need to regenerate kibana's index pattern (tipically if you are now extracting an additional field into elasticsearch),
you'll need to:

- install [elasticdump](https://www.npmjs.com/package/elasticdump)
- dump your kibana's index pattern as follows:

```bash
elasticdump --input='http://<elasitc_search_host>:9200/.kibana' --output=$ --type=data --searchBody '{"query":{"term":{"_id": "gerrit"}}}' | jq .
```
- Save the output into **kibana-config/2_index-pattern.kibana.data.json** file