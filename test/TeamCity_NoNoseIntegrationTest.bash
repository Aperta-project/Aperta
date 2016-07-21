!/bin/bash
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
cd test/frontend/assets
wget http://bighector.plos.org/aperta/testing_assets.tar.gz
gunzip testing_assets.tar.gz
tar --warning=no-unknown-keyword -xf testing_assets.tar
rm testing_assets.tar
cd ../..
rm Output/*.png
rm Base/*.pyc
rm frontend/*.pyc
rm frontend/Pages/*.pyc
python -m frontend.test_addl_info_task
python -m frontend.test_admin
python -m frontend.test_assign_team
python -m frontend.test_authors_task
python -m frontend.test_bdd_cns
python -m frontend.test_bdd_create_to_submit
python -m frontend.test_changes_for_author
python -m frontend.test_dashboard
python -m frontend.test_discussion_forum
python -m frontend.test_figure_task
python -m frontend.test_final_tech_check
python -m frontend.test_initial_decision_card
python -m frontend.test_initial_tech_check
python -m frontend.test_invite_ae_card
python -m frontend.test_invite_reviewers
python -m frontend.test_journal_admin
python -m frontend.test_login
python -m frontend.test_manuscript_viewer
python -m frontend.test_metadata_versioning
python -m frontend.test_paper_tracker
python -m frontend.test_production_metadata_card
python -m frontend.test_profile
python -m frontend.test_register_decision
python -m frontend.test_reviewer_candidates
python -m frontend.test_revise_task
python -m frontend.test_revision_tech_check
python -m frontend.test_title_abstract_card
python -m frontend.test_withdraw_ms
python -m frontend.test_workflow
