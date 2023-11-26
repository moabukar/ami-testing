#!/bin/bash

nodeid=`docker info --format '{{json .Swarm.NodeID}}'| sed "s/\"//g"`
managerstatus=`docker node ls --filter "id=$nodeid" --format "{{.ManagerStatus}}"`
tokenbearer=$(curl -sk --connect-timeout 5 -d '{"username":"admin","password":"Password"}' https://ucp.dev.hcp.corp.hmrc.gov.uk/auth/login | jq -r .auth_token)
version=$(curl -k -X GET "https://ucp.dev.hcp.corp.hmrc.gov.uk/version" -H  "accept: application/json" -H  "Authorization: Bearer $tokenbearer" | jq '.Components[] | select(.Name | contains("Universal Control Plane")) | .Version' | sed 's/"//g')

if [[ "$managerstatus" == "Leader" ]]
then
  clusterid=`docker info --format '{{json .Swarm.Cluster.ID}}'| sed "s/\"//g"`
  docker container run --rm -i --name ucp --log-driver none -v /var/run/docker.sock:/var/run/docker.sock docker/ucp:$version backup --id $clusterid > backup.tar
  aws s3 cp backup.tar s3://hcp-hmrcdockerswarmdev/swarmbucket/docker/ucp/backup.tar --region eu-west-2
else
  echo "I am Not A Leader"
fi
