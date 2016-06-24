#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates style and function of Revision Tech Check
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import random
import time

from selenium.common.exceptions import NoSuchElementException

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import users, editorial_users
from frontend.common_test import CommonTest
from Cards.revision_tech_check_card import RTCCard
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'sbassi@plos.org'

@MultiBrowserFixture
class RTCCardTest(CommonTest):
  """
  Validate the elements, styles, functions of the Revision Tech Check card
  """

  def test_rtc_card(self):
    """
    test_revision_tech_check: Validates the elements, styles, and functions of RTC Card
    :return: void function
    """
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat',
                        type_='NoCards',
                        random_bit=True,
                        )
    dashboard_page.restore_timeout()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=15)
    paper_canonical_url = manuscript_page.get_current_url().split('?')[0]
    paper_id = paper_canonical_url.split('/')[-1]
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
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
    dashboard_page = self.cas_login(email=editorial_user['email'])
    paper_workflow_url = '{0}/workflow'.format(paper_canonical_url)
    self._driver.get(paper_workflow_url)
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the workflow page to load and for the elements to attach to DOM,
    # otherwise failures
    time.sleep(4)
    # Check if FTC card is there, if not, add it.
    if not workflow_page.is_card('Revision Tech Check'):
      workflow_page.add_card('Revision Tech Check')
    rtc_card = RTCCard(self.getDriver())
    workflow_page.click_revision_tech_check_card()
    rtc_card.validate_styles(paper_id)
    data = rtc_card.complete_card()
    rtc_card.click_autogenerate_btn()
    time.sleep(2)
    issues_text = rtc_card.get_issues_text()
    for index, checked in enumerate(data):
      if not checked and rtc_card.email_text[index]:
        assert rtc_card.email_text[index] in issues_text, \
            '{0} (Not checked item #{1}) not in {2}'.format(rtc_card.email_text[index],
                index, issues_text)
      elif checked and rtc_card.email_text[index]:
        assert rtc_card.email_text[index] not in issues_text, \
            '{0} (Checked item #{1}) not in {2}'.format(rtc_card.email_text[index],
                index, issues_text)
    time.sleep(2)
    rtc_card.click_send_changes_btn()
    all_success_messages = rtc_card.get_flash_success_messages()
    success_msgs = [msg.text.split('\n')[0] for msg in all_success_messages]
    assert 'Author Changes Letter has been Saved' in success_msgs, success_msgs
    assert 'The author has been notified via email that changes are needed. They will also '\
        'see your message the next time they log in to see their manuscript.' in success_msgs,\
        success_msgs
    # Check not error message
    try:
      rtc_card._get(rtc_card._flash_error_msg)
      # Note: Commenting out due to APERTA-7012
      #raise ElementExistsAssertionError('There is an unexpected error message')
      logging.warning('There is an error message because of APERTA-7012')
    except ElementDoesNotExistAssertionError:
      pass

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
