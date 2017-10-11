#!/usr/bin/env bash

export PATH="$HOME/bin:$HOME/.pyenv/bin:$PATH"

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
# Command Line script for TeamCity build job for test run
# Depends on
# env.APERTA_PSQL_DBNAME
# env.APERTA_PSQL_HOST
# env.APERTA_PSQL_PORT
# env.APERTA_PSQL_PW
# env.APERTA_PSQL_USER
# env.DISPLAY
# env.SELENIUM_GRID_URL
# env.WEBDRIVER_TARGET_URL
# being set as Environment Variables

# Stop the script if any single command fails
set -e

wget https://github.com/mozilla/geckodriver/releases/download/v0.18.0/geckodriver-v0.18.0-linux32.tar.gz
tar -xvzf geckodriver*
chmod +x geckodriver
mv geckodriver /opt/teamcity/bin/
rm geckodriver-v0.18.0-linux32.tar.gz

SCRIPT_DIR=%teamcity.build.workingDir%/test
ASSETS_DIR=$SCRIPT_DIR/frontend/assets

pyenv activate tahi-int3
pyenv version

cd $ASSETS_DIR
wget http://bighector.plos.org/aperta/testing_assets.tar.gz
TESTING_ASSETS="testing_assets.tar.gz"
if tar --version | grep -q 'gnu'; then
  echo "Detected GNU tar"
  tar --warning=no-unknown-keyword -vxf $TESTING_ASSETS
else
  echo "Detected non-GNU tar"
  tar -vxf $TESTING_ASSETS
fi
rm $TESTING_ASSETS
cd $SCRIPT_DIR
export PYTHONPATH="$SCRIPT_DIR/Base:$SCRIPT_DIR:$PYTHONPATH"
# Reverses 'set -e'. Allows the script to continue through failures.
set +e

rm Output/*.png
rm Base/*.pyc
rm frontend/*.pyc
rm frontend/Pages/*.pyc
# rm frontend/__init__.py

pytest -v --teamcity frontend/

pyenv deactivate
pyenv version

