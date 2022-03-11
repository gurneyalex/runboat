#!/bin/bash

set -exo pipefail

# Remove initialization sentinel, in case we are reinitializing.
rm -fr /mnt/data/initialized

# Remove addons dir, in case we are reinitializing after a previously
# failed installation.
rm -fr $ADDONS_DIR
# Download the repository at git reference into $ADDONS_DIR.
mkdir -p $ADDONS_DIR
cd $ADDONS_DIR
curl -sSL https://github.com/${RUNBOAT_GIT_REPO}/tarball/${RUNBOAT_GIT_REF} | tar zxf - --strip-components=1

# Install.
INSTALL_METHOD=${INSTALL_METHOD:-oca_install_addons}
if [[ "${INSTALL_METHOD}" == "oca_install_addons" ]] ; then
    oca_install_addons
elif [[ "${INSTALL_METHOD}" == "editable_pip_install" ]] ; then
    pip install -e .
else
    echo "Unsupported INSTALL_METHOD: '${INSTALL_METHOD}'"
    exit 1
fi

# Keep a copy of the venv that we can re-use for shorter startup time.
DEBIAN_FRONTEND=noninteractive apt-get -yqq update
DEBIAN_FRONTEND=noninteractive apt-get -yqq install rsync
rsync -a --delete /opt/odoo-venv/ /mnt/data/odoo-venv

touch /mnt/data/initialized
