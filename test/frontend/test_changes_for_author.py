#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates style and function of Initial Tech Check
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import random
import time

from selenium.common.exceptions import NoSuchElementException

from Base.CustomException import ElementDoesNotExistAssertionError, ElementExistsAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import creator_login1, creator_login2, creator_login3, creator_login4, \
    creator_login5, staff_admin_login, internal_editor_login, prod_staff_login, pub_svcs_login, \
    super_admin_login, academic_editor_login, users, editorial_users
from frontend.common_test import CommonTest
from Cards.initial_tech_check_card import ITCCard
from Cards.revision_tech_check_card import RTCCard
from Cards.final_tech_check_card import FTCCard
from Tasks.changes_for_author_task import ChangesForAuthorTask
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class CFACardTest(CommonTest):
  """
  The Changes for Author card is generated automatically by the completion of the ITC, RTC, and/or
    FTC cards if there is anything registered on those cards that needs to be addressed. Currently,
    those cards will only trigger the creation of a Changes for Author card IF the publishing_state
    of the manuscript = 'submitted', otherwise an error is thrown on sending changes to the author.

    Note that no tests of the ITC/RTC/FTC cards are contemplated here as these are handled in their
      own test cases. We are covering only state changes, generation of the card, and UI elements
      and the function of the "These changes have been made" button.
  """
  email_text = {0: 'In the Ethics statement card, you have selected Yes to one of the '
      'questions. In the box provided, please include the appropriate approval information, '
      'as well as any additional requirements listed.',
                1: '',
                2: 'In the Data Availability card, you have selected Yes in response to '
      'Question 1, but you have not fill in the text box under Question 2 explaining how '
      'your data can be accessed. Please choose the most appropriate option from the list '
      'and paste into the text box.',
                3: 'In the Data Availability card, you have mentioned your data has been '
      'submitted to the Dryad repository. Please provide the reviewer URL in the text box '
      'under question 2 so that your submitted data can be reviewed.',
                4: 'The list of authors in your manuscript file does not match the list of '
      'authors in the Authors card. Please ensure these are consistent.',
                5: 'Please provide a unique and current email address for each contributing '
      'author. It is important that you provide a working email address as we will contact '
      'each author to confirm authorship.',
                6: '',
                7: 'In the Competing Interests card, you have selected Yes, but not provided '
      'an explanation in the box provided. Please take this opportunity to include all '
      'relevant information.',
                8: 'Please complete the Financial Disclosure card. This section should '
      'describe sources of funding that have supported the work. Please include relevant '
      'grant numbers and the URL of any funder\'s Web site. If the funders had a role in the '
      'manuscript, please include a description in the box provided.',
                9: '',
                10: '',
                11: 'We are unable to preview or download Figure [X]. Please upload a higher '
      'quality version, preferably in TIF or EPS format and ensure the uploaded version can '
      'be previewed and downloaded before resubmitting your manuscript.',
                12: 'Please remove captions from figure or supporting information files and '
      'ensure each file has a caption present in the manuscript.',
                13: 'Please provide a caption for [file name] in the manuscript file.',
                14: 'Please note you have cited a file, [file name], in your manuscript that '
      'has not been included with your submission. Please upload this file, or if this file '
      'was cited in error, please remove the corresponding citation from your manuscript.',
                15: 'Please upload a \'Response to Reviewers\' Word document in the Supporting'
      ' Information card. This file should address all reviewer comments from the original '
      'submission point-by-point.',
                }

  def test_cfa_from_itc_card(self):
    """
    test_changes_for_author: Test the creation of the Changes for Author card from the ITC card.
    Validates the elements, styles, roles and functions of Changes for Author card, including
    publishing state transitions
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
    paper_url = manuscript_page.get_current_url().split('?')[0]
    paper_id = manuscript_page.get_paper_db_id()
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.close_modal()
    # Paper MUST be in submitted state to continue
    db_submission_data = manuscript_page.get_db_submission_data(paper_id)
    initial_post_submit_state = db_submission_data[0][0]
    logging.info('Current publishing state is {0}'.format(initial_post_submit_state))
    assert initial_post_submit_state == 'submitted', initial_post_submit_state

    # logout and enter as editor
    manuscript_page.logout()
    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    paper_workflow_url = '{0}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the workflow page to load and for the elements to attach to DOM,
    # otherwise failures
    time.sleep(4)
    # add card ITC with add new card if not present
    # Check if card is there
    if not workflow_page.is_card('Initial Tech Check'):
      workflow_page.add_card('Initial Tech Check')
    # click on ITC
    itc_card = ITCCard(self.getDriver())
    workflow_page.click_initial_tech_check_card()
    data = itc_card.complete_card()
    itc_card.click_autogenerate_btn()
    time.sleep(2)
    issues_text = itc_card.get_issues_text()
    for index, checked in enumerate(data):
      if not checked and self.email_text[index]:
        assert self.email_text[index] in issues_text, \
            '{0} (Not checked item #{1}) not in {2}'.format(self.email_text[index],
                index, issues_text)
      elif checked and self.email_text[index]:
        assert self.email_text[index] not in issues_text, \
            '{0} (Checked item #{1}) not in {2}'.format(self.email_text[index],
                index, issues_text)
    time.sleep(1)
    itc_card.click_send_changes_btn()
    all_success_messages = itc_card.get_flash_success_messages()
    success_msgs = [msg.text.split('\n')[0] for msg in all_success_messages]
    assert 'Author Changes Letter has been Saved' in success_msgs, success_msgs
    assert 'The author has been notified via email that changes are needed. They will also '\
        'see your message the next time they log in to see their manuscript.' in success_msgs,\
        success_msgs
    # Check not error message
    try:
      itc_card._get(itc_card._flash_error_msg)
      # Note: Commenting out due to APERTA-7012
      #raise ElementExistsAssertionError('There is an unexpected error message')
      logging.warning('WARNING: An error message fired on Send Changes to Author for ITC card')
    except ElementDoesNotExistAssertionError:
      pass

    # Paper MUST be in Checking state to at this point
    new_db_submission_data = manuscript_page.get_db_submission_data(paper_id)
    post_itc_state = new_db_submission_data[0][0]
    logging.info('Current publishing state is {0}'.format(post_itc_state))
    assert post_itc_state == 'checking', post_itc_state
    workflow_page.logout()

    # Now log back in as the creator user and access Changes for Author card from accordion view
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    self._driver.get(paper_url)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('changes_for_author')
    cfa_task = ChangesForAuthorTask(self.getDriver())
    time.sleep(1)
    cfa_task.validate_styles()
    cfa_task.complete_cfa_card()
    cfa_task.check_flash_messages('Thank you. Your changes have been sent to PLOS Wombat.')

    # Finally validate publishing state transition
    final_db_submission_data = manuscript_page.get_db_submission_data(paper_id)
    cfa_complete_state = final_db_submission_data[0][0]
    logging.info('Current publishing state is {0}'.format(cfa_complete_state))
    assert cfa_complete_state == 'submitted', cfa_complete_state


  def test_cfa_from_rtc_card(self):
    """
    test_changes_for_author: Test the creation of the Changes for Author card from the RTC card.
    Validates the elements, styles, roles and functions of Changes for Author card, including
    publishing state transitions
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
    paper_url = manuscript_page.get_current_url().split('?')[0]
    paper_id = manuscript_page.get_paper_db_id()
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.close_modal()
    # Paper MUST be in submitted state to continue
    db_submission_data = manuscript_page.get_db_submission_data(paper_id)
    initial_post_submit_state = db_submission_data[0][0]
    logging.info('Current publishing state is {0}'.format(initial_post_submit_state))
    assert initial_post_submit_state == 'submitted', initial_post_submit_state

    # logout and enter as editor
    manuscript_page.logout()
    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    paper_workflow_url = '{0}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the workflow page to load and for the elements to attach to DOM,
    # otherwise failures
    time.sleep(4)
    # add card ITC with add new card if not present
    # Check if card is there
    if not workflow_page.is_card('Revision Tech Check'):
      workflow_page.add_card('Revision Tech Check')
    # click on RTC
    rtc_card = RTCCard(self.getDriver())
    workflow_page.click_revision_tech_check_card()
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
    time.sleep(1)
    rtc_card.click_send_changes_btn()
    all_success_messages = rtc_card.get_flash_success_messages()
    success_msgs = [msg.text.split('\n')[0] for msg in all_success_messages]
    assert 'Author Changes Letter has been Saved' in success_msgs, success_msgs
    assert 'The author has been notified via email that changes are needed. They will also ' \
           'see your message the next time they log in to see their manuscript.' in success_msgs, \
      success_msgs
    # Check not error message
    try:
      rtc_card._get(itc_card._flash_error_msg)
      # Note: Commenting out due to APERTA-7012
      # raise ElementExistsAssertionError('There is an unexpected error message')
      logging.warning('WARNING: An error message fired on Send Changes to Author for RTC card')
    except ElementDoesNotExistAssertionError:
      pass

    # Paper MUST be in Checking state to at this point
    new_db_submission_data = manuscript_page.get_db_submission_data(paper_id)
    post_rtc_state = new_db_submission_data[0][0]
    logging.info('Current publishing state is {0}'.format(post_rtc_state))
    assert post_rtc_state == 'checking', post_rtc_state
    workflow_page.logout()

    # Now log back in as the creator user and access Changes for Author card from accordion view
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    self._driver.get(paper_url)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('changes_for_author')
    cfa_task = ChangesForAuthorTask(self.getDriver())
    time.sleep(1)
    cfa_task.validate_styles()
    cfa_task.complete_cfa_card()
    cfa_task.check_flash_messages('Thank you. Your changes have been sent to PLOS Wombat.')

    # Finally validate publishing state transition
    final_db_submission_data = manuscript_page.get_db_submission_data(paper_id)
    cfa_complete_state = final_db_submission_data[0][0]
    logging.info('Current publishing state is {0}'.format(cfa_complete_state))
    assert cfa_complete_state == 'submitted', cfa_complete_state


  def test_cfa_from_ftc_card(self):
    """
    test_changes_for_author: Test the creation of the Changes for Author card from the FTC card.
    Validates the elements, styles, roles and functions of Changes for Author card, including
    publishing state transitions
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
    paper_url = manuscript_page.get_current_url().split('?')[0]
    paper_id = manuscript_page.get_paper_db_id()
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.close_modal()
    # Paper MUST be in submitted state to continue
    db_submission_data = manuscript_page.get_db_submission_data(paper_id)
    initial_post_submit_state = db_submission_data[0][0]
    logging.info('Current publishing state is {0}'.format(initial_post_submit_state))
    assert initial_post_submit_state == 'submitted', initial_post_submit_state

    # logout and enter as editor
    manuscript_page.logout()
    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    paper_workflow_url = '{0}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the workflow page to load and for the elements to attach to DOM,
    # otherwise failures
    time.sleep(4)
    # add card ITC with add new card if not present
    # Check if card is there
    if not workflow_page.is_card('Final Tech Check'):
      workflow_page.add_card('Final Tech Check')
    # click on FTC
    ftc_card = FTCCard(self.getDriver())
    workflow_page.click_final_tech_check_card()
    data = ftc_card.complete_card()
    ftc_card.click_autogenerate_btn()
    time.sleep(2)
    issues_text = ftc_card.get_issues_text()
    for index, checked in enumerate(data):
      if not checked and self.email_text[index]:
        assert self.email_text[index] in issues_text, \
          '{0} (Not checked item #{1}) not in {2}'.format(self.email_text[index],
                                                          index, issues_text)
      elif checked and self.email_text[index]:
        assert self.email_text[index] not in issues_text, \
          '{0} (Checked item #{1}) not in {2}'.format(self.email_text[index],
                                                      index, issues_text)
    time.sleep(1)
    ftc_card.click_send_changes_btn()
    all_success_messages = ftc_card.get_flash_success_messages()
    success_msgs = [msg.text.split('\n')[0] for msg in all_success_messages]
    assert 'Author Changes Letter has been Saved' in success_msgs, success_msgs
    assert 'The author has been notified via email that changes are needed. They will also ' \
           'see your message the next time they log in to see their manuscript.' in success_msgs, \
      success_msgs
    # Check not error message
    try:
      ftc_card._get(ftc_card._flash_error_msg)
      # Note: Commenting out due to APERTA-7012
      # raise ElementExistsAssertionError('There is an unexpected error message')
      logging.warning('WARNING: An error message fired on Send Changes to Author for ITC card')
    except ElementDoesNotExistAssertionError:
      pass

    # Paper MUST be in Checking state to at this point
    new_db_submission_data = manuscript_page.get_db_submission_data(paper_id)
    post_ftc_state = new_db_submission_data[0][0]
    logging.info('Current publishing state is {0}'.format(post_ftc_state))
    assert post_ftc_state == 'checking', post_ftc_state
    workflow_page.logout()

    # Now log back in as the creator user and access Changes for Author card from accordion view
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    self._driver.get(paper_url)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('changes_for_author')
    cfa_task = ChangesForAuthorTask(self.getDriver())
    time.sleep(1)
    cfa_task.validate_styles()
    cfa_task.complete_cfa_card()
    cfa_task.check_flash_messages('Thank you. Your changes have been sent to PLOS Wombat.')

    # Finally validate publishing state transition
    final_db_submission_data = manuscript_page.get_db_submission_data(paper_id)
    cfa_complete_state = final_db_submission_data[0][0]
    logging.info('Current publishing state is {0}'.format(cfa_complete_state))
    assert cfa_complete_state == 'submitted', cfa_complete_state


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
