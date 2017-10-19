#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates style and function of Preprint Posting Card
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import os
import random
import time

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users, handling_editor_login, academic_editor_login, staff_admin_login, \
  super_admin_login, prod_staff_login, pub_svcs_login
from frontend.Cards.preprint_posting_card import PrePrintPostCard
from frontend.common_test import CommonTest
from .Cards.revision_tech_check_card import RTCCard
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.workflow_page import WorkflowPage

__author__ = 'gholmes@plos.org'
external_editorial_users = [handling_editor_login, academic_editor_login]
editorial_users =          [super_admin_login,pub_svcs_login,]


@MultiBrowserFixture
class PPCardTest(CommonTest):
  """
  Validate the elements, styles, functions of the Revision Tech Check card
  """

  def test_pp_card(self):
    """
    test_preprint_post_card: Validates the elements, styles, and functions of PP Card
    :return: void function
    """
    logging.info('Test PPC')
    current_path = os.getcwd()
    logging.info(current_path)
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='NoCards', random_bit=True)
    dashboard_page.restore_timeout()
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_canonical_url = manuscript_page.get_current_url().split('?')[0]
    paper_id = paper_canonical_url.split('/')[-1]
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.complete_task('Title And Abstract')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()
    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    self.cas_login(email=editorial_user['email'])
    paper_workflow_url = '{0}/workflow'.format(paper_canonical_url)
    self._driver.get(paper_workflow_url)
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the workflow page to load and for the elements to attach to DOM,
    # otherwise failures
    time.sleep(4)
    # Check if PPC card is there, if not, add it.
    if not workflow_page.is_card('Preprint Posting'):
        workflow_page.page_ready()
    workflow_page.add_card('Preprint Posting')
    pp_card = PrePrintPostCard(self.getDriver())
    workflow_page.click_preprint_posting_card()
    pp_card.validate_styles()
    pp_card.card_ready()
    pp_card.is_yes_button_checked()
    pp_card.click_completion_button()
    pp_card.completed_state()
    # Checking elements are not clickable
    pp_card.elementstate()
    pp_card.click_close_button_bottom()
    workflow_page.logout()
    external_editorial_user=random.choice(external_editorial_users)
    logging.info('Logging in as {0}'.format(external_editorial_user))
    self.cas_login(email=external_editorial_user['email'])
    paper_workflow_url = '{0}/workflow'.format(paper_canonical_url)
    self._driver.get(paper_workflow_url)
    pp_card.check_for_flash_error()

    if __name__ == '__main__':
      CommonTest._run_tests_randomly()
