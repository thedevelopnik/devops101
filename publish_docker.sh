#! /usr/bin/env bash
# checked with shellcheck

if [ -z "$2" ]; then
  echo "Supply dockerhub username" 1>&2
  exit 1
fi

if [ -z "$2" ]; then
  echo "Supply dockerhub password" 1>&2
  exit 1
fi

if [ -z "$3" ]; then
  echo 'Supply a branch to be used for tagging. (i.e. ${CIRCLE_BRANCH}' 1>&2
  exit 1
fi

if [ -z "$4" ]; then
  echo 'Supply a SHA1 value to be used for SHA tagging. (i.e. ${CIRCLE_SHA1}' 1>&2
  exit 1
fi

DOCKER_USERNAME=$1
DOCKER_PASSWORD=$2
BRANCH=$3
SHA=$4
SHORT_SHA=${SHA:0:7}

REPOSITORY="thedevelopnik/devops101"

docker build \
  --tag "$REPOSITORY:$BRANCH-$SHORT_SHA" \
  --no-cache \
  .

# push the built image to the created repo with appropriate tags
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
docker push "$REPOSITORY:$BRANCH-$SHORT_SHA"
