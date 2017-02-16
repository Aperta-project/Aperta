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
from Base.Resources import staff_admin_login, users, editorial_users
from Pages.workflow_page import WorkflowPage
from Pages.manuscript_viewer import ManuscriptViewerPage
from frontend.Tasks.new_taxon_task import NewTaxonTask
from frontend.Cards.new_taxon_card import NewTaxonCard

__author__ = 'scadavid@plos.org'

@MultiBrowserFixture
class NewTaxonTest(CommonTest):
  """
  Validate the elements of the New Taxon Card and Task
  Validate styles for both reports in both edit and view mode in both contexts (task and card)
  """

  def test_new_taxon_task(self):
    """
    test_new_taxon: Validates the elements of the front-matter New Taxon Task.
    :return: None
    """
    logging.info('Test New Taxon Task::front_matter')
    current_path = os.getcwd()
    logging.info('test_new_taxon_task')
    # Create base data - new papers
    creator_user = random.choice(users)
    logging.info(creator_user)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='generateCompleteApexData')
    dashboard_page.restore_timeout()
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # Abbreviate the timeout for conversion success message
    manuscript_page.page_ready_post_create()
    # Note: Request title to make sure the required page is loaded
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    data = manuscript_page.complete_task('New Taxon')
    logging.info('Completed Taxonomy data: {0}'.format(data))
    # logout and enter as editor
    time.sleep(3)
    manuscript_page.logout()
    # Enter as Editorial User
    editorial_user = random.choice(editorial_users)
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    card_title = 'New Taxon'
    workflow_page.click_card('new_taxon', card_title)
    new_taxon_card = NewTaxonCard(self.getDriver())
    new_taxon_card.card_ready()
    new_taxon_card.validate_card_elements_styles(short_doi)
    logging.info('Reviewing data: {0}'.format(data))
    new_taxon_card.validate_taxon_questions_answers(data)

  # Disable for APERTA-8500
  def _test_new_taxon_style(self):
    """
    test_new_taxon_style: Validates the styles of the front-matter New Taxon Task.
    :return: None
    """
    logging.info('Test New Taxon Task Style::front_matter')
    current_path = os.getcwd()
    logging.info('test_new_taxon_task_style')
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
    data = manuscript_page.complete_task('New Taxon', \
        data=[{'checkbox': False, 'compliance': False}, {'checkbox': False, 'compliance': False}])
    logging.info('Completed Taxonomy data: {0}'.format(data))
    new_taxon_task = NewTaxonTask(self._driver)
    new_taxon_task.validate_task_elements_styles()
    # logout and enter as editor
    manuscript_page.logout()
            
if __name__ == '__main__':
  CommonTest._run_tests_randomly()