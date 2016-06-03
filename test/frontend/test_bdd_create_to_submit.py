#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import creator_login1, creator_login2, creator_login3, creator_login4, \
    creator_login5, staff_admin_login, super_admin_login
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

users = [creator_login1,
         creator_login2,
         creator_login3,
         creator_login4,
         creator_login5,
         ]
admin_users = [staff_admin_login, super_admin_login]

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
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # The flash success message is not loading in all cases, even for successful conversion
    #   temporarily disabling it. replacing with a sleep
    time.sleep(15)
    # manuscript_page.validate_ihat_conversions_success()
    # manuscript_page.close_flash_message()
    time.sleep(2)
    paper_title_from_page = manuscript_page.get_paper_title_from_page()
    logging.info('paper_title_from_page: {0}'.format(paper_title_from_page.encode('utf8')))
    paper_id = manuscript_page.get_current_url().split('papers/')[1].split('?')[0]
    logging.info('paper_id: {0}'.format(paper_id))
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
    manuscript_page.validate_ihat_conversions_success(timeout=15, fail_on_missing=True)
    time.sleep(2)
    paper_title_from_page = manuscript_page.get_paper_title_from_page()
    paper_url = manuscript_page.get_current_url()
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_url))
    paper_id = paper_url.split('papers/')[1]
    manuscript_page.click_submit_btn()
    manuscript_page.validate_so_overlay_elements_styles('full_submit', paper_title_from_page)
    manuscript_page.confirm_submit_cancel()
    # The overlay must be cleared to interact with the submit button
    # and it takes time
    time.sleep(.5)
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay

    manuscript_page.validate_so_overlay_elements_styles('congrats_is', paper_title_from_page)
    manuscript_page.close_submit_overlay()
    manuscript_page.validate_initial_submit_success()
    sub_data = manuscript_page.get_db_submission_data(paper_id)
    assert sub_data[0][0] == 'initially_submitted', sub_data[0][0]
    assert sub_data[0][1] == True, 'Gradual Engagement: ' + sub_data[0][1]
    assert sub_data[0][2], sub_data[0][2]
    manuscript_page.logout()

    admin_user = random.choice(admin_users)
    self.cas_login(email=admin_user['email'])
    # Need time to finish initial redirect to dashboard page
    time.sleep(3)
    new_paper_url = paper_url + '/workflow'
    self._driver.get(new_paper_url)
    self._driver.navigated = True
    time.sleep(5)
    workflow_page = WorkflowPage(self.getDriver())
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
    # Need time to finish initial redirect to dashboard page
    time.sleep(3)
    self._driver.get(paper_url)
    self._driver.navigated = True
    time.sleep(2)
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
