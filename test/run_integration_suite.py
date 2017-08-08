from pprint import pprint
import unittest

'''
This is a test suite containing the same tests as the "NoNose" bash script.
It is for local use and doesn't perform all the setup that the bash script does.
'''

loader = unittest.TestLoader()
suite = unittest.TestSuite()


try:
  suite.addTests(loader.loadTestsFromName('frontend.test_ad_hoc'))
  suite.addTests(loader.loadTestsFromName('frontend.test_addl_info_task'))
  suite.addTests(loader.loadTestsFromName('frontend.test_admin'))
  suite.addTests(loader.loadTestsFromName('frontend.test_assign_team'))
  suite.addTests(loader.loadTestsFromName('frontend.test_authors_task'))
  suite.addTests(loader.loadTestsFromName('frontend.test_bdd_cns'))
  suite.addTests(loader.loadTestsFromName('frontend.test_bdd_create_to_submit'))
  suite.addTests(loader.loadTestsFromName('frontend.test_changes_for_author'))
  suite.addTests(loader.loadTestsFromName('frontend.test_cover_letter'))
  suite.addTests(loader.loadTestsFromName('frontend.test_dashboard'))
  suite.addTests(loader.loadTestsFromName('frontend.test_discussion_forum'))
  suite.addTests(loader.loadTestsFromName('frontend.test_early_article_posting'))
  suite.addTests(loader.loadTestsFromName('frontend.test_figure_task'))
  suite.addTests(loader.loadTestsFromName('frontend.test_final_tech_check'))
  suite.addTests(loader.loadTestsFromName('frontend.test_initial_decision_card'))
  suite.addTests(loader.loadTestsFromName('frontend.test_initial_tech_check'))
  suite.addTests(loader.loadTestsFromName('frontend.test_invite_ae_card'))
  suite.addTests(loader.loadTestsFromName('frontend.test_invite_reviewers'))
  suite.addTests(loader.loadTestsFromName('frontend.test_login'))
  suite.addTests(loader.loadTestsFromName('frontend.test_manuscript_viewer'))
  suite.addTests(loader.loadTestsFromName('frontend.test_metadata_versioning'))
  suite.addTests(loader.loadTestsFromName('frontend.test_new_taxon'))
  suite.addTests(loader.loadTestsFromName('frontend.test_paper_tracker'))
  suite.addTests(loader.loadTestsFromName('frontend.test_production_metadata_card'))
  suite.addTests(loader.loadTestsFromName('frontend.test_profile'))
  suite.addTests(loader.loadTestsFromName('frontend.test_reactivate_ms'))
  suite.addTests(loader.loadTestsFromName('frontend.test_register_decision'))
  suite.addTests(loader.loadTestsFromName('frontend.test_reporting_guidelines'))
  suite.addTests(loader.loadTestsFromName('frontend.test_reviewer_candidates'))
  suite.addTests(loader.loadTestsFromName('frontend.test_reviewer_report'))
  suite.addTests(loader.loadTestsFromName('frontend.test_revise_task'))
  suite.addTests(loader.loadTestsFromName('frontend.test_revision_tech_check'))
  suite.addTests(loader.loadTestsFromName('frontend.test_send_to_apex'))
  suite.addTests(loader.loadTestsFromName('frontend.test_supporting_information'))
  suite.addTests(loader.loadTestsFromName('frontend.test_title_abstract_card'))
  suite.addTests(loader.loadTestsFromName('frontend.test_upload_ms'))
  suite.addTests(loader.loadTestsFromName('frontend.test_withdraw_ms'))
  suite.addTests(loader.loadTestsFromName('frontend.test_workflow'))

  runner = unittest.TextTestRunner(verbosity=3)
except Exception as e:
  pprint(e)

finally:
  result = runner.run(suite)
  pprint(result.failures)
  pprint(result.errors)