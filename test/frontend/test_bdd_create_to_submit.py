#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, admin_users
from frontend.common_test import CommonTest
from Cards.initial_decision_card import InitialDecisionCard
from Pages.dashboard import DashboardPage
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

"""
This behavioral test case validates the Aperta Create New Submission through Submit process.
This test requires the following data:
A journal named "PLOS Wombat"
An MMT in that journal with no cards populated in its workflow, named "NoCards"
An MMT in that journal with only the initial decision card populated in its workflow,
    named "OnlyInitialDecisionCard"
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
__author__ = 'jgray@plos.org'

cards = ['cover_letter',
         'billing',
         'figures',
         'authors',
         'supporting_info',
         'upload_manuscript',
         'addl_info_task',
         'review_candidates',
         'revise_task',
         'competing_interests',
         'data_availability',
         'ethics_statement',
         'financial_disclosure',
         'new_taxon',
         'reporting_guidelines',
         'changes_for_author',
         ]


@MultiBrowserFixture
class ApertaBDDCreatetoNormalSubmitTest(CommonTest):
  """
  Self imposed AC:
  Two separate tests: First test: Normal Submit
  1. Login as Author
  2. Create doc for full submission mmt
  3. Confirm db state for:
     publishing_state: unsubmitted
     gradual_engagement: true
  4. submit manuscript
  5. validate overlay elements and styles
  6. cancel submit
  7. ensure overlay clears Submit button still present
  8. submit again
  9. confirm submit
  10. ensure overlay clears Submitted message appears, submit button no longer shown
  11. Confirm db state for:
      publishing_state: submitted
      submitted_at: neither NULL nor ''
  """
  def test_validate_full_submit(self, init=True):
    """
    test_bdd_create_to_submit: Validates creating a new document and making a full submission
    :param init: Determine if login is needed
    :return: void function
    """
    logging.info('Test BDDCreatetoNormalSubmitTest::validate_full_submit')
    current_path = os.getcwd()
    logging.info(current_path)
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login() if init else DashboardPage(self.getDriver())
    # Temporary changing timeout
    dashboard_page.click_create_new_submission_button()
    dashboard_page.set_timeout(120)
    # We recently became slow drawing this overlay (20151006)
    time.sleep(.5)
    self.create_article(journal='PLOS Wombat',
                        type_='NoCards',
                        random_bit=True,
                        title='full submit',
                        )
    dashboard_page.restore_timeout()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(15)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    # Need to wait for url to update
    count = 0
    paper_id = manuscript_page.get_current_url().split('/')[-1]
    while not paper_id:
      if count > 60:
        raise (StandardError, 'Paper id is not updated after a minute, aborting')
      time.sleep(1)
      paper_id = manuscript_page.get_current_url().split('/')[-1]
      count += 1
    paper_id = paper_id.split('?')[0] if '?' in paper_id else paper_id
    logging.info("Assigned paper id: {0}".format(paper_id))

    count = 0
    while count < 60:
      paper_title_from_page = manuscript_page.get_paper_title_from_page()
      if 'full submit' in paper_title_from_page.encode('utf8'):
        count += 1
        time.sleep(1)
        continue
      else:
        break
      logging.warning('Conversion never completed - still showing interim title')

    logging.info('paper_title_from_page: {0}'.format(paper_title_from_page.encode('utf8')))
    # Allow time for submit button to attach to the DOM
    time.sleep(3)
    manuscript_page.click_submit_btn()
    time.sleep(3)
    manuscript_page.validate_so_overlay_elements_styles('full_submit', paper_title_from_page)
    manuscript_page.confirm_submit_cancel()
    # The overlay mush be cleared to interact with the submit button
    # and it takes time
    time.sleep(.5)
    manuscript_page.click_submit_btn()
    time.sleep(1)
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay

    manuscript_page.validate_so_overlay_elements_styles('congrats', paper_title_from_page)
    manuscript_page.close_submit_overlay()
    manuscript_page.validate_submit_success()
    sub_data = manuscript_page.get_db_submission_data(paper_id)
    assert sub_data[0][0] == 'submitted', sub_data[0][0]
    assert sub_data[0][1] == False, 'Gradual Engagement: ' + sub_data[0][1]
    assert sub_data[0][2], sub_data[0][2]


@MultiBrowserFixture
class ApertaBDDCreatetoInitialSubmitTest(CommonTest):
  """
  Self imposed AC:
  Two separate tests: Second test: Initial Submit
  1. Login as Author
  2. Create doc for initial submission mmt
  3. Confirm db state for:
     publishing_state: unsubmitted
     gradual_engagement: true
  4. submit manuscript
  5. validate initial submit overlay elements and styles
  6. cancel submit
  7. ensure overlay clears Submit button still present
  8. submit again
  9. confirm submit
  10. ensure overlay clears Submitted message appears, submit button no longer shown
  11. Confirm db state for:
      publishing_state: initially_submitted
      submitted_at: neither NULL nor ''
  12. Log out as Author, Log in as Admin
  13. Open workflow page for document created in step 2)
  14. Open Initial Decision Card
  15. Randomly select to either:
      a. Reject; or
      b. Invite for Full Submission
  16. Enter appropriate text for email
  17. Click send feedback
  18. Close Card
  19. Confirm db state for:
      publishing state: a. rejected or b. in_revision
      If rejected, end test
  20. Log out as Admin, Log in as Author
  21. Open the relevant paper in the manuscript viewer, ensure editable and Submit (full)
  22. validate initial submit (final) overlay elements and style
  23. cancel submit
  24. resubmit (full)
  25. confirm submit
  26. Confirm db state for:
      publishing_state: submitted
      gradual_engagement: true
  """
  def test_validate_initial_submit(self):
    """
    test_bdd_create_to_submit: Validates creating a new document and making an initial submission,
      bringing it through to full submission
    :param init: Determine if login is needed
    :return: void function
    """
    logging.info('Test BDDCreatetoNormalSubmitTest::validate_initial_submit')
    current_path = os.getcwd()
    logging.info(current_path)
    creator_user = random.choice(users)
    logging.info('Logging in as user: {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.click_create_new_submission_button()
    # Temporary changing timeout
    dashboard_page.set_timeout(60)
    # We recently became slow drawing this overlay (20151006)
    time.sleep(.5)
    self.create_article(journal='PLOS Wombat',
                        type_='OnlyInitialDecisionCard',
                        random_bit=True,
                        title='initial submit',
                        )
    dashboard_page.restore_timeout()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(7)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    time.sleep(5)
    # Need to wait for url to update
    count = 0
    paper_id = manuscript_page.get_current_url().split('/')[-1]
    while not paper_id:
      if count > 60:
        raise (StandardError, 'Paper id is not updated after a minute, aborting')
      time.sleep(1)
      paper_id = manuscript_page.get_current_url().split('/')[-1]
      count += 1
    paper_id = paper_id.split('?')[0] if '?' in paper_id else paper_id
    logging.info("Assigned paper id: {0}".format(paper_id))

    count = 0
    while count < 60:
      paper_title_from_page = manuscript_page.get_paper_title_from_page()
      if 'initial submit' in paper_title_from_page.encode('utf8'):
        count += 1
        time.sleep(1)
        continue
      else:
        break
      logging.warning('Conversion never completed - still showing interim title')

    # Give a little time for the submit button to attach to the DOM
    time.sleep(5)
    manuscript_page.click_submit_btn()
    manuscript_page.validate_so_overlay_elements_styles('full_submit', paper_title_from_page)
    manuscript_page.confirm_submit_cancel()
    # The overlay must be cleared to interact with the submit button
    # and it takes time
    time.sleep(2)
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(3)
    manuscript_page.check_for_flash_error()
    manuscript_page.validate_so_overlay_elements_styles('congrats_is', paper_title_from_page)
    manuscript_page.close_submit_overlay()
    manuscript_page.validate_initial_submit_success()
    sub_data = manuscript_page.get_db_submission_data(paper_id)
    assert sub_data[0][0] == 'initially_submitted', sub_data[0][0]
    assert sub_data[0][1] == True, 'Gradual Engagement: ' + sub_data[0][1]
    assert sub_data[0][2], sub_data[0][2]
    manuscript_page.logout()

    admin_user = random.choice(admin_users)
    logging.info('Logging in as {0}'.format(admin_user['name']))
    dashboard_page = self.cas_login(email=admin_user['email'])
    dashboard_page._wait_for_element(
      dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    workflow_page.click_card('initial_decision')
    id_card = InitialDecisionCard(self.getDriver())
    id_card.validate_styles()
    decision = id_card.execute_decision()
    logging.info('Decision: {0}'.format(decision))
    time.sleep(2)
    sub_data = workflow_page.get_db_submission_data(paper_id)
    if decision == 'reject':
      assert sub_data[0][0] == 'rejected', sub_data[0][0]
      assert sub_data[0][1] == True, 'Gradual Engagement: ' + sub_data[0][1]
      assert sub_data[0][2], sub_data[0][2]
      return True
    elif decision == 'invite':
      assert sub_data[0][0] == 'invited_for_full_submission', sub_data[0][0]
      assert sub_data[0][1] == True, 'Gradual Engagement: ' + sub_data[0][1]
      assert sub_data[0][2], sub_data[0][2]
    else:
      print('ERROR: no initial decision rendered')
      print(decision)
      return False
    workflow_page.logout()

    self.cas_login(email=creator_user['email'])
    dashboard_page._wait_for_element(
      dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    paper_title_from_page = manuscript_page.get_paper_title_from_page()
    time.sleep(1)
    manuscript_page.click_submit_btn()
    manuscript_page.validate_so_overlay_elements_styles('initial_submit_full',
                                                        paper_title_from_page)
    manuscript_page.confirm_submit_cancel()
    # The overlay mush be cleared to interact with the submit button
    # and it takes time
    time.sleep(1)
    manuscript_page.click_submit_btn()
    time.sleep(1)
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(1)
    manuscript_page.validate_so_overlay_elements_styles('congrats_is_full', paper_title_from_page)
    manuscript_page.close_submit_overlay()
    manuscript_page.validate_submit_success()
    sub_data = manuscript_page.get_db_submission_data(paper_id)
    assert sub_data[0][0] == 'submitted', sub_data[0][0]
    assert sub_data[0][1] == True, 'Gradual Engagement: ' + sub_data[0][1]
    assert sub_data[0][2], sub_data[0][2]

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
