#!/usr/bin/env bash

set -e
set -u
set -o pipefail

source ${SCRIPTS_LIB_DIR}/utils.sh

BASEDIR=$1
cd ${BASEDIR}
repo=mx

echo ">>> MX_GITHUB_ORG = ${MX_GITHUB_ORG:-[not set]}"
echo ">>> MX_REPO_BRANCH = ${MX_REPO_BRANCH:-[not set]}"

gitClone ${MX_GITHUB_ORG:-graalvm} \
         ${repo}                   \
         ${MX_REPO_BRANCH:-master} \
         "${repo} is a build tool created for managing the development of (primarily) Java code"

export MX=${BASEDIR}/${repo}/mx

cd ${BASEDIR}/mx

echo "Applying and checking patch to mx.py..."
git apply ${SCRIPTS_LIB_DIR}/patch/mx.py_logs_jvm_cli_opts.patch || true
grep "logv(\"opts" -B 2 ${BASEDIR}/mx/mx.py                      || true
grep "self.java_args))" -B 2 ${BASEDIR}/mx/mx.py                 || true
cd ${BASEDIR}