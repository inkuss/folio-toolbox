#!/bin/bash
for moduleIds in `curl -w '\n' -XGET http://localhost:9130/_/discovery/modules | jq '.[] | .srvcId + "/" + .instId'`; do
  # strip off quotes
  moduleIds="${moduleIds%\"}"
  moduleIds="${moduleIds#\"}"
  cmd="curl -w '\n' -D - -X DELETE http://localhost:9130/_/discovery/modules/$moduleIds"
  echo "executing command: $cmd"
  $cmd
done
