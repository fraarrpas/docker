#!/bin/bash
set -e


export JAVA_OPTIONS="${JAVA_OPTS} ${GN_CONFIG_PROPERTIES}"

if [ "$1" = 'catalina.sh' ]; then

	mkdir -p "$DATA_DIR"

	#Set geonetwork data dir
	export CATALINA_OPTS="$CATALINA_OPTS -Dgeonetwork.dir=$DATA_DIR"
fi

exec "$@"
