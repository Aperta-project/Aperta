#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test validates the Send to Apex workflow
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from frontend.common_test import CommonTest
from Base.Resources import staff_admin_login, users, editorial_users
from Pages.workflow_page import WorkflowPage
from Pages.manuscript_viewer import ManuscriptViewerPage
from Tasks.upload_manuscript_task import UploadManuscriptTask
from frontend.Cards.send_to_apex_card import SendToApexCard

__author__ = 'scadavid@plos.org'

@MultiBrowserFixture
class SendToApexTest(CommonTest):
  """
  Validate the elements of the Send to Apex Card
  Validate if the data in the frontend match the data in the backend sent to Apex
  """

  def test_failure_to_apex(self):
    """
    test_failure_to_apex: Validate if the Send to Apex card display the corresponding errors
    """
    logging.info('test_failure_to_apex')
    # Create base data - new papers
    creator_user = random.choice(users)
    logging.info(creator_user)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='NoCards')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    # Request title to make sure the required page is loaded
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.page_ready()
    manuscript_page.close_modal()
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
    # Disable Upload Manuscript Task
    data = manuscript_page.complete_task('Upload Manuscript', click_override=True)
    # go to workflow
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    card_title = 'Send to Apex'
    workflow_page.click_card('send_to_apex', card_title)
    send_to_apex_card = SendToApexCard(self.getDriver())
    send_to_apex_card.click_send_to_apex_button()
    send_to_apex_card.validate_send_to_apex_error_message()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()