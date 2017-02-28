#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates style and function of Final Tech Check
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import os
import random
import time

from selenium.common.exceptions import NoSuchElementException

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import users, editorial_users
from frontend.common_test import CommonTest
from Cards.final_tech_check_card import FTCCard
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'sbassi@plos.org'


@MultiBrowserFixture
class FTCCardTest(CommonTest):
  """
  Validate the elements, styles, functions of the Final Tech Check card
  """

  def test_ftc_card(self):
    """
    test_final_tech_check: Validates the elements, styles, and functions of FTC Card
    :return: void function
    """
    logging.info('Test FTC')
    current_path = os.getcwd()
    logging.info(current_path)
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='NoCards', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # Need to wait for url to update
    count = 0
    short_doi = manuscript_page.get_current_url().split('/')[-1]
    while not short_doi:
      if count > 60:
        raise (StandardError, 'Short doi is not updated after a minute, aborting')
      time.sleep(1)
      short_doi = manuscript_page.get_current_url().split('/')[-1]
      count += 1
    short_doi = short_doi.split('?')[0] if '?' in short_doi else short_doi
    logging.info("Assigned paper short doi: {0}".format(short_doi))

    manuscript_page.page_ready_post_create()
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    manuscript_page._wait_for_element(manuscript_page._get(manuscript_page._overlay_header_close))
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()

    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page._wait_for_element(
      dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))

    # Check if FTC card is there, if not, add it.
    if not workflow_page.is_card('Final Tech Check'):
      workflow_page.add_card('Final Tech Check')
    ftc_card = FTCCard(self.getDriver())
    workflow_page.click_final_tech_check_card()
    ftc_card.validate_styles(short_doi)
    data = ftc_card.complete_card()
    ftc_card.click_autogenerate_btn()
    time.sleep(2)
    issues_text = ftc_card.get_issues_text()
    for index, checked in enumerate(data):
      if not checked and ftc_card.email_text[index]:
        assert ftc_card.email_text[index] in issues_text, \
            '{0} (Not checked item #{1}) not in {2}'.format(ftc_card.email_text[index],
                index, issues_text)
      elif checked and ftc_card.email_text[index]:
        assert ftc_card.email_text[index] not in issues_text, \
            '{0} (Checked item #{1}) not in {2}'.format(ftc_card.email_text[index],
                index, issues_text)
    ftc_card.click_send_changes_btn()
    all_success_messages = ftc_card.get_flash_success_messages()
    success_msgs = [msg.text.split('\n')[0] for msg in all_success_messages]
    assert 'Author Changes Letter has been Saved' in success_msgs, success_msgs
    assert 'The author has been notified via email that changes are needed. They will also '\
        'see your message the next time they log in to see their manuscript.' in success_msgs,\
        success_msgs
    # Check not error message
    try:
      ftc_card._get(ftc_card._flash_error_msg)
      # Note: Commenting out due to APERTA-7012
      #raise ElementExistsAssertionError('There is an unexpected error message')
      logging.warning('There is an error message because of APERTA-7012')
    except ElementDoesNotExistAssertionError:
      pass

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
