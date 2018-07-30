set -e
set -o errexit
set -o nounset
set -o pipefail

BASE_DIR="/srv/deployment/search/mjolnir"
VENV="${BASE_DIR}/venv"
DEPLOY_DIR="${BASE_DIR}/deploy"
MJOLNIR_DIR="${BASE_DIR}/deploy/src"
WHEEL_DIR="${DEPLOY_DIR}/artifacts"
REQUIREMENTS="${DEPLOY_DIR}/requirements-frozen.txt"
MJOLNIR_ZIP="${BASE_DIR}/mjolnir_venv.zip"

PIP="${VENV}/bin/pip"

# Check if we have an old python2 virtualenv
if [ -x "$PIP" ]; then
    if "${VENV}/bin/python" -c 'import sys; sys.exit(sys.version_info[0] == 3)'; then
        rm -rf "${VENV}"
    fi
fi

# Ensure that the virtual environment exists. Don't recreate if already
# existing, as this will try and downgrade pip on debian jessie from the one
# installed later which then breaks pip.
if [ ! -x "$PIP" ]; then
    mkdir -p "$VENV"
    virtualenv --never-download --python python3 $VENV || /bin/true
fi

# Debian jessie based hosts need updated versions of pip and wheel or they will
# fail to install some binary packages (numpy, scipy, maybe others)
$PIP install \
    -vv \
    --no-index \
    --find-links "${WHEEL_DIR}" \
    --upgrade \
    --force-reinstall \
    pip wheel
# Install or upgrade our packages
$PIP install \
    -vv \
    --no-index \
    --find-links "${WHEEL_DIR}" \
    --upgrade \
    --force-reinstall \
    -r "${REQUIREMENTS}"

$PIP install \
    -vv \
    --no-index \
    --upgrade \
    --no-deps \
    "${MJOLNIR_DIR}"

# Build a .zip of the virtualenv that can be shipped to spark workers if
# we are on a host with spark installed.
if command -v spark-submit > /dev/null; then
    cd "${VENV}"
    zip -qr ${MJOLNIR_ZIP}.tmp .
    mv -T ${MJOLNIR_ZIP}.tmp ${MJOLNIR_ZIP}
fi
