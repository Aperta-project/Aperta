#!/bin/bash
# Command Line script for TeamCity build job for test run
# Depends on
# env.VALID_PW
# env.JOURNAL
# env.MMT
# env.WEBDRIVER_TARGET_URL
# being set as Environment Variables
cd frontend/assets
wget http://bighector.plos.org/aperta/testing_assets.tar.gz
gunzip testing_assets.tar.gz
tar --warning=no-unknown-keyword -xf testing_assets.tar
rm testing_assets.tar
cd ../..
rm Output/*.png
rm Base/*.pyc
rm frontend/*.pyc
rm frontend/Pages/*.pyc
python -m frontend.test_deploy_verify

