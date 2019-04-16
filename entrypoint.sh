#!/bin/bash

set -e

logger() {
  printf '%s (%s) %s [%s]: %s\n' "$(date --iso-8601=seconds)" "$(whoami)" "${BASH_SOURCE}" "${1}" "${2}"
}

# Restore original default config if no config has been provided
if [[ ! "$(ls -A /etc/nginx/conf.d)" ]]; then
    logger "INFO" "Restore original default config. copying over /etc/nginx/.conf.d.orig to /etc/nginx/conf.d"
    cp -a /etc/nginx/.conf.d.orig/. /etc/nginx/conf.d 2>/dev/null
fi

if [[ ! "$(ls -A /var/www/public)" ]]; then
    logger "INFO" "Empty /var/www/public. copying over default nginx html file"
    cp -a /usr/share/nginx/html/*.html /var/www/public/ 2>/dev/null
fi

# Replace variables $ENV{<environment varname>}
function ReplaceEnvironmentVariable() {
    grep -rl "\$ENV{\"$1\"}" $3|xargs -r \
        sed -i "s|\\\$ENV{\"$1\"}|$2|g"
}

if [ -n "$DEBUG" ]; then
    echo "Environment variables:"
    env
    echo "..."
fi

echo "Environment variables:"
env
echo "..."

# Replace all variables
for _curVar in `env | awk -F = '{print $1}'`;do
    # awk has split them by the equals sign
    # Pass the name and value to our function
    ReplaceEnvironmentVariable ${_curVar} ${!_curVar} /etc/nginx/conf.d/*
done

exec "${@}"