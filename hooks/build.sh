#!/bin/bash

# norby/nginx-alpine:1.1
TAG="${REPO_NAME}:${VERSION}"

set -x
docker build . \
    --no-cache \
    -t "$TAG" \
    --build-arg VERSION=$VERSION \
    --build-arg BASE_IMAGE=$BASE_IMAGE

image_id=$(docker images $TAG --format "{{.ID}}")

docker images

for extra_tag in ${EXTRA_TAGS//;/$'\n'}
do
    echo $TAG
    echo $extra_tag
    docker tag $TAG "${REPO_NAME}:${extra_tag}"
done

docker run --rm $TAG nginx -c /etc/nginx/nginx.conf -t