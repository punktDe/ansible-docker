#! /usr/bin/env bash
action=$1
network_name=$2
subnet=$3
driver=$4

tempfolder="/tmp/docker-networks"
mkdir -p $tempfolder

case $action in 
  start)
    docker network create --driver=$driver --subnet=$subnet $network_name
    containers_in_network="$tempfolder/containers_in_network_$network_name"
    if [ -f "$containers_in_network" ]; then
      for i in `cat $containers_in_network`; do
        echo $i
        docker network connect $network_name $i;
      done;
    fi;
    rm -f $containers_in_network
    ;;
  reload)
    containers_in_network=`docker network inspect -f '{{range .Containers}}{{.Name}} {{.IPv4Address}} {{end}}' $network_name`

    while IFS= read -r line; do 
      container=`echo $line | awk '{print $1}'`
      docker network disconnect -f $network_name $container; 
    done <<< "$containers_in_network"

    docker network rm $network_name
    docker network create --driver=$driver --subnet=$subnet $network_name

    while IFS= read -r line; do 
      container=`echo $line | awk '{print $1}'`
      ip=`echo $line | awk '{print substr($2, 1, (length($2)-3))}'`
      docker network connect $network_name $container --ip $ip; 
    done <<< "$containers_in_network"
    ;;
  stop)
    containers_in_network=`docker network inspect -f '{{range .Containers}}{{.Name}} {{.IPv4Address}} {{end}}' $network_name`


    echo $containers_in_network > "$tempfolder/containers_in_network_$network_name"

    while IFS= read -r line; do 
      container=`echo $line | awk '{print $1}'`
      docker network disconnect -f $network_name $container; 
    done <<< "$containers_in_network"

    docker network rm $network_name
    ;;
esac
