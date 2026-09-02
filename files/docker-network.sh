#!/usr/bin/env bash
#
# Manage a single docker network on behalf of a systemd unit.
#
# Containers attached to the network are remembered while the unit is stopped
# and reconnected with the exact same IP addresses once it is started again,
# so that containers configured with a static IP survive a network rebuild.
#
# Usage: docker-network.sh {start|reload|stop} <name> <subnet> <driver>

set -euo pipefail

action="${1:?missing action}"
network_name="${2:?missing network name}"
subnet="${3:?missing subnet}"
driver="${4:?missing driver}"

state_dir="/run/docker-networks"
state_file="${state_dir}/${network_name}"

# Prints one "<container> <ip>/<prefix>" line per attached container.
attached_containers() {
  docker network inspect \
    --format '{{ range .Containers }}{{ .Name }} {{ .IPv4Address }}{{ println }}{{ end }}' \
    "$network_name" 2>/dev/null || true
}

network_exists() {
  docker network inspect "$network_name" >/dev/null 2>&1
}

create_network() {
  if network_exists; then
    return 0
  fi
  docker network create --driver="$driver" --subnet="$subnet" "$network_name"
}

remove_network() {
  if ! network_exists; then
    return 0
  fi
  docker network rm "$network_name"
}

# Reconnects the containers described on stdin, keeping their IP addresses.
connect_containers() {
  local container address
  while read -r container address; do
    [ -n "$container" ] || continue
    if [ -n "$address" ]; then
      docker network connect --ip="${address%/*}" "$network_name" "$container" ||
        echo "warning: could not reconnect ${container} to ${network_name} with ${address}" >&2
    else
      docker network connect "$network_name" "$container" ||
        echo "warning: could not reconnect ${container} to ${network_name}" >&2
    fi
  done
  return 0
}

disconnect_containers() {
  local container
  while read -r container _; do
    [ -n "$container" ] || continue
    docker network disconnect --force "$network_name" "$container" ||
      echo "warning: could not disconnect ${container} from ${network_name}" >&2
  done
  return 0
}

case "$action" in
  start)
    create_network
    if [ -f "$state_file" ]; then
      connect_containers <"$state_file"
      rm -f "$state_file"
    fi
    ;;
  reload)
    containers="$(attached_containers)"
    printf '%s\n' "$containers" | disconnect_containers
    remove_network
    create_network
    printf '%s\n' "$containers" | connect_containers
    ;;
  stop)
    containers="$(attached_containers)"
    mkdir -p "$state_dir"
    printf '%s\n' "$containers" >"$state_file"
    printf '%s\n' "$containers" | disconnect_containers
    remove_network
    ;;
  *)
    echo "usage: ${0##*/} {start|reload|stop} <name> <subnet> <driver>" >&2
    exit 64
    ;;
esac
