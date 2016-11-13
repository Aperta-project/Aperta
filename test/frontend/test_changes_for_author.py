#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates style and function of Initial Tech Check
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import os
import random
import time

from Base.CustomException import ElementDoesNotExistAssertionError, ElementExistsAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
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

  def test_cfa_from_itc_card(self):
    """
    test_changes_for_author: Test the creation of the Changes for Author card from the ITC card.
    Validates the elements, styles, roles and functions of Changes for Author card, including
    publishing state transitions
    :return: void function
    """
    logging.info('Test Changes For Author::cfa_from_itc')
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
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    paper_id = manuscript_page.get_paper_id_from_url()
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()

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
    dashboard_page._wait_for_element(
        dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())

    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    # add card ITC with add new card if not present
    # Check if card is there
    if not workflow_page.is_card('Initial Tech Check'):
      workflow_page.add_card('Initial Tech Check')
    # click on ITC
    itc_card = ITCCard(self.getDriver())
    workflow_page.click_initial_tech_check_card()
    data = itc_card.complete_card()
    itc_card.click_autogenerate_btn()
    # TODO: Figure out a way to eliminate this explicit wait
    time.sleep(2)
    issues_text = itc_card.get_issues_text()
    for index, checked in enumerate(data):
      if not checked and itc_card.email_text[index]:
        assert itc_card.email_text[index] in issues_text, \
            '{0} (Not checked item #{1}) not in {2}'.format(itc_card.email_text[index],
                                                            index, issues_text)
      elif checked and itc_card.email_text[index]:
        assert itc_card.email_text[index] not in issues_text, \
            '{0} (Checked item #{1}) not in {2}'.format(itc_card.email_text[index],
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
      # raise ElementExistsAssertionError('There is an unexpected error message')
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
    dashboard_page._wait_for_element(
        dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page._wait_for_element(manuscript_page._get(manuscript_page._cfa_task))
    manuscript_page.click_task('changes_for_author')
    cfa_task = ChangesForAuthorTask(self.getDriver())
    cfa_task._wait_for_element(cfa_task._get(cfa_task._card_heading))
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
    logging.info('Test Changes For Author::cfa_from_rtc')
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
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    paper_id = manuscript_page.get_paper_id_from_url()
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()

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
    dashboard_page._wait_for_element(
        dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # go to wf
    paper_viewer.click_workflow_link()

    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    # add card RTC with add new card if not present
    # Check if card is there
    if not workflow_page.is_card('Revision Tech Check'):
      workflow_page.add_card('Revision Tech Check')
    # click on RTC
    rtc_card = RTCCard(self.getDriver())
    workflow_page.click_revision_tech_check_card()
    data = rtc_card.complete_card()
    rtc_card.click_autogenerate_btn()
    # TODO: Figure out a way to eliminate this explicit wait
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
      rtc_card._get(rtc_card._flash_error_msg)
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
    dashboard_page._wait_for_element(
        dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page._wait_for_element(manuscript_page._get(manuscript_page._cfa_task))
    manuscript_page.click_task('changes_for_author')
    cfa_task = ChangesForAuthorTask(self.getDriver())
    cfa_task._wait_for_element(cfa_task._get(cfa_task._card_heading))
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
    logging.info('Test Changes For Author::cfa_from_ftc')
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
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    paper_id = manuscript_page.get_paper_id_from_url()
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()

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
    dashboard_page._wait_for_element(
        dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # go to wf
    paper_viewer.click_workflow_link()

    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    # add card FTC with add new card if not present
    # Check if card is there
    if not workflow_page.is_card('Final Tech Check'):
      workflow_page.add_card('Final Tech Check')
    # click on FTC
    ftc_card = FTCCard(self.getDriver())
    workflow_page.click_final_tech_check_card()
    data = ftc_card.complete_card()
    ftc_card.click_autogenerate_btn()
    # TODO: Figure out a way to eliminate this explicit wait
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
    dashboard_page._wait_for_element(
        dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page._wait_for_element(manuscript_page._get(manuscript_page._cfa_task))
    manuscript_page.click_task('changes_for_author')
    cfa_task = ChangesForAuthorTask(self.getDriver())
    cfa_task._wait_for_element(cfa_task._get(cfa_task._card_heading))
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
