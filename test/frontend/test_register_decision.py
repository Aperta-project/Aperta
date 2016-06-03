#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates Paper submission and Register Decision.
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted into
    frontend/assets/
"""
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import creator_login1, creator_login2, creator_login3, creator_login4, \
    creator_login5, staff_admin_login
from frontend.common_test import CommonTest
from Cards.initial_decision_card import InitialDecisionCard
from Cards.register_decision_card import RegisterDecisionCard
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'jgray@plos.org'

users = [creator_login1,
         creator_login2,
         creator_login3,
         creator_login4,
         creator_login5,
         ]


@MultiBrowserFixture
class RegisterDecisionCardTest(CommonTest):
  """
  1. Editor can indicate their decision
  2. Text box for reject or invitation letter is blank.
  3. Editor can customize the text that will be sent to authors.
  4. Email should be sent to creating author/corresponding author
  5. The publishing_state should be updated accordingly
  6. The version should be updated accordingly
  """

  def test_register_decision_actions(self):
    """
    test_register_decision: Validates the elements, styles and functions of the register decision
      card from new document creation through initial_decision, resubmission and then registering a
      final decision
    :return: void function
    """
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat',
                        type_='Images+InitialDecision',
                        random_bit=True,
                        )
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    dashboard_page.restore_timeout()
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=15)
    # Note: Request title to make sure the required page is loaded
    paper_id = manuscript_page.get_paper_db_id()
    time.sleep(2)
    # figures
    manuscript_page.click_task('Figures')
    manuscript_page.complete_task('Figures')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()

    # login as staff admin
    dashboard_page = self.cas_login(email=staff_admin_login['email'])
    # look for the article in paper tracker
    # go to paper tracker
    dashboard_page._get(dashboard_page._nav_paper_tracker_link).click()
    # Go to workflow
    url = self._driver.current_url
    paper_url = '{0}//{1}/papers/{2}'.format(url.split('/')[0], url.split('/')[2], paper_id)
    paper_workflow_url = '{0}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    # go to card
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the elements to attach to DOM, otherwise failures
    time.sleep(2)
    workflow_page.click_card('initial_decision')
    # time.sleep(3)
    initial_decision = InitialDecisionCard(self.getDriver())
    assert initial_decision._get(initial_decision._decision_letter_textarea).text == ''
    initial_decision.execute_decision('invite')
    # Test that card is editable by author
    manuscript_page.logout()

    # login as creator, make full submission
    self.cas_login(email=creator_user['email'])
    self._driver.get(paper_url)
    self._driver.navigated = True
    time.sleep(2)
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    time.sleep(2)
    # Need to test for failure messages here - in some cases we are failing submission and then
    #   failing later with a "ValueError: Manuscript is in unexpected state: A decision cannot be
    #   registered at this time. The manuscript is not in a submitted state." message.
    manuscript_page.check_for_flash_error()
    manuscript_page.logout()

    # login as staff admin
    dashboard_page = self.cas_login(email=staff_admin_login['email'])
    # Go to workflow
    url = self._driver.current_url
    paper_url = '{0}//{1}/papers/{2}'.format(url.split('/')[0], url.split('/')[2], paper_id)
    paper_workflow_url = '{0}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    # go to card
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the elements to attach to DOM, otherwise failures
    time.sleep(2)
    workflow_page.click_card('register_decision')
    # time.sleep(3)
    register_decision = RegisterDecisionCard(self.getDriver())
    decisions = ('Accept', 'Reject', 'Major Revision', 'Minor Revision')
    decision = random.choice(decisions)
    register_decision.register_decision(decision)

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
