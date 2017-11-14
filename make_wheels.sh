#!/usr/bin/env bash

set -e
set -o errexit
set -o nounset
set -o pipefail

BASE="$(realpath $(dirname $0))"
BUILD="${BASE}/_build"
VENV="${BUILD}/venv"
MJOLNIR="${BASE}/src"
WHEEL_DIR="${BASE}/artifacts"
REQUIREMENTS="${BASE}/requirements-frozen.txt"

PIP="${VENV}/bin/pip"

# Used by wheel >= 0.25 to normalize timestamps. Timestamp
# taken from original debian patch:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?att=1;bug=776026;filename=wheel_reproducible.patch;msg=5
export SOURCE_DATE_EPOCH=315576060

mkdir -p "${VENV}"
virtualenv --python python2.7 $VENV || /bin/true
$PIP install "${MJOLNIR}"
$PIP freeze --local | grep -v mjolnir | grep -v pkg-resources > $REQUIREMENTS
$PIP install pip wheel
# Debian jessie based hosts require updated pip and wheel packages or they will
# refuse to install some packages (numpy, scipy, maybe others)
$PIP wheel --find-links "${WHEEL_DIR}" \
        --wheel-dir "${WHEEL_DIR}" \
        pip wheel
$PIP wheel --find-links "${WHEEL_DIR}" \
        --wheel-dir "${WHEEL_DIR}" \
        --requirement "${REQUIREMENTS}"

