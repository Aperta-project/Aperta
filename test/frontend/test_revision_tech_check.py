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
  email_text = {0: 'In the Ethics statement card, you have selected Yes to one of the questions.'
      ' In the box provided, please include the appropriate approval information, as well as any'
      ' additional requirements listed.',
                1: '',
                2: 'In the Data Availability card, you have selected Yes in response to Question'
      ' 1, but you have not fill in the text box under Question 2 explaining how your data can '
      'be accessed. Please choose the most appropriate option from the list and paste into the '
      'text box.',
                3: 'In the Data Availability card, you have mentioned your data has been '
      'submitted to the Dryad repository. Please provide the reviewer URL in the text box under '
      'question 2 so that your submitted data can be reviewed.',
                4: 'The list of authors in your manuscript file does not match the list of '
      'authors in the Authors card. Please ensure these are consistent.',
                5: '',
                6: 'In the Competing Interests card, you have selected Yes, but not provided an '
      'explanation in the box provided. Please take this opportunity to include all relevant '
      'information.',
                7: 'Please complete the Financial Disclosure card. This section should describe '
      'sources of funding that have supported the work. Please include relevant grant numbers '
      'and the URL of any funder\'s Web site. If the funders had a role in the manuscript, '
      'please include a description in the box provided.',
                8: '',
                9: 'Please respond to all reviewer comments point-by-point in the Revision '
      'Details section of your Revise Manuscript card.',
                10: '',
                11: 'We are unable to preview or download Figure [X]. Please upload a higher '
      'quality version, preferably in TIF or EPS format and ensure the uploaded version can be '
      'previewed and downloaded before resubmitting your manuscript.',
                12: 'Please remove captions from figure or supporting information files and ensure'
      ' each file has a caption present in the manuscript.',
                13: 'Please provide a caption for [file name] in the manuscript file.',
                14: 'Please note you have cited a file, [file name], in your manuscript that has '
      'not been included with your submission. Please upload this file, or if this file was cited '
      'in error, please remove the corresponding citation from your manuscript.'
                }

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
      if not checked and self.email_text[index]:
        assert self.email_text[index] in issues_text, \
            '{0} (Not checked item #{1}) not in {2}'.format(self.email_text[index],
                index, issues_text)
      elif checked and self.email_text[index]:
        assert self.email_text[index] not in issues_text, \
            '{0} (Checked item #{1}) not in {2}'.format(self.email_text[index],
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
