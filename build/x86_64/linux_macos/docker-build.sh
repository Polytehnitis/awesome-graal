#!/bin/bash

set -e
set -u
set -o pipefail

DEBUG=${DEBUG:-""}

JDK_VERSION="jdk8u152-b16"
DOCKER_IMAGE_TAG="graal-jdk8:latest"
CONTAINER_HOME_DIR="/home/graal"

HOST_OUTPUT_DIR="$(pwd)/jdk8-with-graal-docker"
mkdir -p "${HOST_OUTPUT_DIR}"
BUILD_LOGS="${HOST_OUTPUT_DIR}/docker-build.logs"

CONTAINER_SCRIPTS_DIR="${CONTAINER_HOME_DIR}/scripts"
CONTAINER_OUTPUT_DIR=${OUTPUT_DIR:-"${CONTAINER_HOME_DIR}/output"}

echo "*************************************************"
echo "* "
echo "* Building image and running container ${DOCKER_IMAGE_TAG}"
echo "* "
echo "* Build logs are sent to a separate log, run the below command to see logs"
echo "* tail -f ${HOST_OUTPUT_DIR}/docker-build.logs"
echo "* "
echo "*************************************************"

echo "******************* Parameters ******************"
echo "DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG}"
echo "JDK_VERSION=${JDK_VERSION}"
echo "DEBUG=${DEBUG}"
echo "DEBUG_MODE_ARGS=${DEBUG_MODE_ARGS}"
echo ""
echo "HOST_OUTPUT_DIR=${HOST_OUTPUT_DIR}"
echo "CONTAINER_HOME_DIR=${CONTAINER_HOME_DIR}"
echo "CONTAINER_SCRIPTS_DIR=${CONTAINER_SCRIPTS_DIR}"
echo "CONTAINER_OUTPUT_DIR=${CONTAINER_OUTPUT_DIR}"
echo ""
echo "BUILD_LOGS=${BUILD_LOGS}"
echo "OUTPUT_DIR=${OUTPUT_DIR:-}"
echo "RUN_TESTS=${RUN_TESTS:-}"
echo "*************************************************"

docker build -t ${DOCKER_IMAGE_TAG} .

if [[ "${DEBUG}" = "true" ]]; then
  echo "* Running container ${DOCKER_IMAGE_TAG} in DEBUG mode"
  docker run                                                       \
         --rm                                                      \
         --entrypoint ${CONTAINER_HOME_DIR}/scripts/local-build.sh \
         --env JAVA_VERSION=${JDK_VERSION}                         \
         --env OUTPUT_DIR=${CONTAINER_OUTPUT_DIR}                  \
         --env RUN_TESTS=${RUN_TESTS:-""}                          \
         --volume $(pwd):${CONTAINER_SCRIPTS_DIR}                  \
         --volume ${HOST_OUTPUT_DIR}:${CONTAINER_OUTPUT_DIR}       \
         ${DOCKER_IMAGE_TAG}
else   
  docker run                                                  \
         --rm                                                 \
         --interactive --tty --entrypoint /bin/bash           \
         --env JAVA_VERSION=${JDK_VERSION}                    \
         --env OUTPUT_DIR=${CONTAINER_OUTPUT_DIR}             \
         --env RUN_TESTS=${RUN_TESTS:-""}                     \
         --volume $(pwd):${CONTAINER_SCRIPTS_DIR}             \
         --volume ${HOST_OUTPUT_DIR}:${CONTAINER_OUTPUT_DIR}  \
         ${DOCKER_IMAGE_TAG} &> ${BUILD_LOGS}
fi

echo "*************************************************"
echo "* "
echo "* Finished running container ${DOCKER_IMAGE_TAG}"
echo "* "
echo "*************************************************"
