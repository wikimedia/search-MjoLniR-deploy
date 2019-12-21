#!/bin/bash

set -e
set -o errexit
set -o nounset
set -o pipefail

BASE_DIR="${SCAP_REV_PATH}"
VENV_DIR="${BASE_DIR}/venv"
MJOLNIR_ZIP="${BASE_DIR}/mjolnir_venv.zip"

# Build a .zip of the virtualenv that can be shipped to spark workers if
# we are on a host with spark installed.
cd "${VENV_DIR}"
zip -qr "${MJOLNIR_ZIP}" .
