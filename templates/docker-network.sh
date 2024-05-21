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
    containers_in_network=`docker network inspect -f '{{range .Containers}}{{.Name}} {{end}}' $network_name`
    for i in $containers_in_network; do 
      docker network disconnect -f $network_name $i; 
    done;
    docker network rm $network_name
    docker network create --driver=$driver --subnet=$subnet $network_name
    for i in $containers_in_network; do 
      docker network connect $network_name $i; 
    done;
    ;;
  stop)
    containers_in_network=`docker network inspect -f '{{range .Containers}}{{.Name}} {{end}}' $network_name`
    echo $containers_in_network > "$tempfolder/containers_in_network_$network_name"
    for i in $containers_in_network; do 
      docker network disconnect -f $network_name $i; 
    done;
    docker network rm $network_name
    ;;
esac
