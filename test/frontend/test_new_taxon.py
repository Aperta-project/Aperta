#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates New Taxon Card & Task
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from frontend.common_test import CommonTest
from Base.Resources import staff_admin_login, users
from Pages.workflow_page import WorkflowPage
from Pages.manuscript_viewer import ManuscriptViewerPage

__author__ = 'scadavid@plos.org'

@MultiBrowserFixture
class NewTaxonTest(CommonTest):
  """
  Validate the elements & styles of the New Taxon Card and Task
  Validate styles for both reports in both edit and view mode in both contexts (task and card)
  """

  def test_new_taxon_task(self):
    """
    test_new_taxon: Validates the elements and styles of the front-matter New Taxon Task.
    :return: None
    """
    logging.info('Test New Taxon Task::front_matter')
    current_path = os.getcwd()
    logging.info(current_path)
    logging.info('test_new_taxon_task')
    # Create base data - new papers
    creator_user = random.choice(users)
    logging.info(creator_user)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='generateCompleteApexData')
    dashboard_page.restore_timeout()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # Abbreviate the timeout for conversion success message
    manuscript_page.page_ready_post_create()
    # Note: Request title to make sure the required page is loaded
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    manuscript_page.complete_task('New Taxon')
    # logout and enter as editor
    manuscript_page.logout()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()