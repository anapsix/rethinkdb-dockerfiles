#!/bin/bash
set -e

if [ ${#} -eq 0 ] || [ "${1:0:1}" = '-' ]; then
  [ -n "$DOCKERCLOUD_CONTAINER_FQDN" ] && TUTUM_ARGS+=( --canonical-address $DOCKERCLOUD_CONTAINER_FQDN )
  [ -n "$DOCKERCLOUD_IP_ADDRESS" ] && TUTUM_ARGS+=( --canonical-address ${TUTUM_IP_ADDRESS%/*} )
  if [ -n "$DOCKERCLOUD_SERVICE_HOSTNAME" ]; then
    TRY_UNTIL=$(date +%s -d "+ 30 seconds")
    TUTUM_CLUSTER_HOSTS=0
    for host in $(host -s -t a $DOCKERCLOUD_SERVICE_HOSTNAME | awk '{print $NF}'); do
      echo -n "waiting for $host to become available: " >&2
      while test $[$TRY_UNTIL-$(date +%s)] -gt 0; do
        if ping -q -w 1 -c 1 $host >/dev/null 2>&1; then
          echo "ok" >&2
          let TUTUM_CLUSTER_HOSTS+=1
          TUTUM_ARGS+=( --join $host )
          break
        else
          echo -n "." >&2
        fi
      done
    done
    if [ $DOCKERCLOUD_CLUSTER_HOSTS -lt 2 ]; then
      echo "seems like we are running in single node mode" >&2
      echo "only one node started or cluster discovery timed-out" >&2
    fi
  fi
  #[ -n "$DOCKERCLOUD_ARGS" ] && TUTUM_ARGS+=( --bind all )
  set -- rethinkdb "$@" "${TUTUM_ARGS[@]}"
fi

exec "$@"
