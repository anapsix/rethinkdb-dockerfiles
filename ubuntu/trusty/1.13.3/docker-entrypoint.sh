#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
  [ -n "$DOCKERCLOUD_CONTAINER_FQDN" ] && DOCKERCLOUD_ARGS+=( --canonical-address $DOCKERCLOUD_CONTAINER_FQDN )
  [ -n "$DOCKERCLOUD_IP_ADDRESS" ] && DOCKERCLOUD_ARGS+=( --canonical-address ${DOCKERCLOUD_IP_ADDRESS%/*} )
  if [ -n "$DOCKERCLOUD_SERVICE_FQDN" ]; then
    for host in $(host -s -t a $DOCKERCLOUD_SERVICE_FQDN | awk '{print $NF}'); do
      DOCKERCLOUD_ARGS+=( --join $host )
    done
  fi
  [ -n "$DOCKERCLOUD_ARGS" ] && DOCKERCLOUD_ARGS+=( --bind all )
  set -- rethinkdb "$@" "${DOCKERCLOUD_ARGS[@]}"
fi

exec "$@"
