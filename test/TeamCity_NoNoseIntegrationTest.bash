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

# Reverses 'set -e'. Allows the script to continue through failures.
set +e

rm Output/*.png
rm Base/*.pyc
rm frontend/*.pyc
rm frontend/Pages/*.pyc

python -m frontend.test_ad_hoc
python -m frontend.test_addl_info_task
python -m frontend.test_admin
python -m frontend.test_assign_team
python -m frontend.test_authors_task
python -m frontend.test_bdd_create_to_submit
python -m frontend.test_changes_for_author
python -m frontend.test_cns
python -m frontend.test_co_author_confirmation
python -m frontend.test_cover_letter
python -m frontend.test_dashboard
python -m frontend.test_discussion_forum
python -m frontend.test_early_version
python -m frontend.test_figure_task
python -m frontend.test_final_tech_check
python -m frontend.test_initial_decision_card
python -m frontend.test_initial_tech_check
python -m frontend.test_invite_ae_card
python -m frontend.test_invite_reviewers
python -m frontend.test_login
python -m frontend.test_manuscript_viewer
python -m frontend.test_metadata_versioning
python -m frontend.test_new_taxon
python -m frontend.test_paper_tracker
python -m frontend.test_production_metadata_card
python -m frontend.test_reactivate_ms
python -m frontend.test_register_decision
python -m frontend.test_reporting_guidelines
python -m frontend.test_reviewer_candidates
python -m frontend.test_reviewer_report
python -m frontend.test_revise_task
python -m frontend.test_revision_tech_check
python -m frontend.test_send_to_apex
python -m frontend.test_supporting_information
python -m frontend.test_title_abstract_card
python -m frontend.test_upload_ms
python -m frontend.test_withdraw_ms
python -m frontend.test_workflow
python -m frontend.test_profile
pyenv deactivate
pyenv version
