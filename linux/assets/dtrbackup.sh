#!/bin/bash

nodeid=`docker info --format '{{json .Swarm.NodeID}}'| sed "s/\"//g"`
managerstatus=`docker node ls --filter "id=$nodeid" --format "{{.ManagerStatus}}"`

#Get the Current Running DTR Version
tokenbearer=$(curl -sk --connect-timeout 5 -d '{"username":"admin","password":"Password"}' https://ucp.dev.hcp.corp.hmrc.gov.uk/auth/login | jq -r .auth_token)
version=$(curl -k --connect-timeout 5 -X GET "https://ucp.dev.hcp.corp.hmrc.gov.uk/containers/json?filters=%7B%22network%22%3A%7B%22dtr-ol%22%3Atrue%7D%7D" -H  "accept: application/json" -H  "Authorization: Bearer $tokenbearer" | jq '.[] | select(.Image | contains("registry")) | .Image' | head -1 | sed 's/"//g' | awk -F":" '{print $2}')


if [[ "$managerstatus" == "Leader" ]]
then
  replicas=`curl -s -u admin:Password -k -X GET "https://dtr.shared.hcp.corp.hmrc.gov.uk/api/v0/workers" -H  "accept: application/json" | jq '.workers[] | select(.status=="running") | .id' | sed "s/\"//g"`

  for replica in $replicas
  do
    echo "Backing Up $replica"
    docker run -i --rm docker/dtr:$version backup --ucp-url=ucp.dev.hcp.corp.hmrc.gov.uk --ucp-username=admin --ucp-password=Password --ucp-insecure-tls  --existing-replica-id $replica > backup.tar
    aws s3 cp backup.tar s3://hcp-hmrcdockerswarmdev/swarmbucket/docker/dtr/backup.tar --region eu-west-2
    break
  done
else
    echo "I am Not A Leader"
fi
