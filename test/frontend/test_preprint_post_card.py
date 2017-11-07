#!/usr/bin/env python
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
  super_admin_login, prod_staff_login, pub_svcs_login, external_editorial_users
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
  Validate the elements, styles, functions of the Preprint Posting card
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
    self.create_article(journal='PLOS Wombat', type_='Preprint Eligible Two', random_bit=True)
    dashboard_page.restore_timeout()
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_canonical_url = manuscript_page.get_current_url().split('?')[0]
    paper_id = paper_canonical_url.split('/')[-1]
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    manuscript_page.click_task('Preprint Posting')
    pp_card = PrePrintPostCard(self.getDriver())
    pp_card.card_ready()
    # Verifying State is default Opt In: Opt in Button is selected
    pp_card.complete_form('optIn')
    # Changing State to Opt out: Opt out Button is selected
    pp_card.complete_form('optOut')
    pp_card.click_completion_button()
    pp_card.completed_state()
    pp_card.logout()
    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    self.cas_login(email=editorial_user['email'])
    paper_workflow_url = '{0}/workflow'.format(paper_canonical_url)
    self._driver.get(paper_workflow_url)
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.click_preprint_posting_card()
    pp_card = PrePrintPostCard(self.getDriver())
    pp_card.click_completion_button()
    #Validating State: Opt out Button is selected
    pp_card.validate_state('optOut')
    pp_card.validate_styles()
    #Changing State: Opt in button will be selected
    pp_card.complete_form('optIn')
    pp_card.validate_state('optOut')


    if __name__ == '__main__':
      CommonTest._run_tests_randomly()
