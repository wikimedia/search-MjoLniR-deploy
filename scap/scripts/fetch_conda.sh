#!/bin/bash

set -e
set -o errexit
set -o nounset
set -o pipefail

DEPLOY_DIR="${SCAP_REV_PATH}"
VENV_DIR="${DEPLOY_DIR}/venv"
PYTHON="venv/bin/python"

ENV_URL="${DEPLOY_DIR}/conda_venv.url"
ENV_TGZ="${DEPLOY_DIR}/conda_venv.tgz"

test -f "${ENV_TGZ}" || wget -O "${ENV_TGZ}" -i "${ENV_URL}"
mkdir "${VENV_DIR}"
tar -C "${VENV_DIR}" -zxf "${ENV_TGZ}"
