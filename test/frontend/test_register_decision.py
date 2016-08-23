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
from Base.Resources import users, editorial_users, staff_admin_login
from frontend.common_test import CommonTest
from Cards.initial_decision_card import InitialDecisionCard
from Cards.register_decision_card import RegisterDecisionCard
from Pages.dashboard import DashboardPage
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'jgray@plos.org'


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

  def test_smoke_register_decision_style(self):
    """
    test_title_abstract_card: Validate components and styles of the Title and Abstract card
    :return: void function
    """
    creator = random.choice(users)
    journal = 'PLOS Wombat'
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page._wait_for_element(
      dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    # Create paper
    dashboard_page.click_create_new_submission_button()
    dashboard_page._wait_for_element(dashboard_page._get(dashboard_page._cns_paper_type_chooser))
    paper_type = 'NoCards'
    logging.info('Creating Article in {0} of type {1}'.format(journal, paper_type))
    self.create_article(title='Testing Register Decision Card',
                        journal=journal,
                        type_=paper_type,
                        random_bit=True,
                        )
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # check for flash message
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    paper_id = manuscript_page.get_paper_id_from_url()
    manuscript_page._wait_for_element(manuscript_page._get(manuscript_page._submit_button))
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page._wait_for_element(manuscript_page._get(manuscript_page._overlay_header_close))
    manuscript_page.close_modal()
    manuscript_page.logout()

    # log as editor - validate T&A Card
    staff_user = random.choice(editorial_users)
    logging.info('Logging in as user: {0}'.format(staff_user['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    cns_button = dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn)
    dashboard_page._wait_for_element(cns_button)
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    workflow_page.click_card('register_decision')
    regdec = RegisterDecisionCard(self.getDriver())
    regdec._wait_for_element(regdec._get(regdec._decision_labels))
    regdec.validate_card_header(paper_id)
    regdec.validate_styles()

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
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    # Note: Request title to make sure the required page is loaded
    paper_id = manuscript_page.get_paper_id_from_url()
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
    dashboard = self.cas_login(email=staff_admin_login['email'])
    dashboard._wait_for_element(dashboard._get(dashboard._dashboard_create_new_submission_btn))
    # Go to workflow
    url = self._driver.current_url
    paper_url = '{0}//{1}/papers/{2}'.format(url.split('/')[0], url.split('/')[2], paper_id)
    paper_workflow_url = '{0}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    # go to card
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._initial_decision_card))
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
    keep_waiting = True
    while keep_waiting:
      time.sleep(5)
      paper_title_from_page = manuscript_page.get_paper_title_from_page()
      if 'full submit' in paper_title_from_page.encode('utf8'):
        continue
      else:
        keep_waiting = False
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
