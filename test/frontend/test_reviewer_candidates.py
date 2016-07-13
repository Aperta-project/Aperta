#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates the reviewer candidates task and card.
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted into
    frontend/assets/
"""

import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, reviewer_login, editorial_users
from Cards.reviewer_candidates_card import ReviewerCandidatesCard
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage
from Tasks.reviewer_candidates_task import ReviewerCandidatesTask

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class ReviewerCandidatesTaskTest(CommonTest):
  """
  1. Creator can recommend or oppose a reviewer
  """

  def test_smoke_reviewer_candidates_styles(self):
    """
    test_reviewer_candidates: Validates the elements, styles of the reviewer candidates task and
      card from new document creation through making a recommendation through
      view of that data on the reviewer candidates card
    :return: void function
    """
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat',
                        type_='generateCompleteApexData',
                        random_bit=True,
                        title='Reviewer Candidates Test'
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
    manuscript_page.click_task('review_candidates')
    time.sleep(3)
    rev_cand_task = ReviewerCandidatesTask(self.getDriver())
    time.sleep(1)
    rev_cand_task.validate_styles()
    rev_cand_task.logout()

    # login as privileged user to validate the presentation of the data on the RC Card
    staff_user = random.choice(editorial_users)
    logging.info('Logging in as user: {0}'.format(['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    time.sleep(3)
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    time.sleep(3)
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    time.sleep(2)
    workflow_page.click_card('reviewer_candidates')
    time.sleep(10)
    rcc = ReviewerCandidatesCard(self.getDriver())
    rcc.validate_styles(reviewer_login, paper_id)

  def test_core_add_reviewer_candidate(self):
    """
    test_reviewer_candidates_task: Validates the submission of a recommended or opposed reviewer.
      Validates the presentation of the data submitted from the task on the workflow card. Note
      that this also validates the styling of the candidate display on the card - as this isn't
      covered in the style validation due to lack of an entry.
    :return: void function
    """
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat',
                        type_='generateCompleteApexData',
                        random_bit=True,
                        title='Reviewer Candidates Test'
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
    manuscript_page.click_task('review_candidates')
    time.sleep(3)
    rev_cand_task = ReviewerCandidatesTask(self.getDriver())
    time.sleep(2)
    choice, reason = rev_cand_task.complete_reviewer_cand_form(reviewer_login)
    rev_cand_task.click_completion_button()
    rev_cand_task.check_for_flash_error()
    rev_cand_task.logout()

    # login as privileged user to validate the presentation of the data on the RC Card
    staff_user = random.choice(editorial_users)
    logging.info('Logging in as user: {0}'.format(['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    time.sleep(3)
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    time.sleep(3)
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    time.sleep(2)
    workflow_page.click_card('reviewer_candidates')
    time.sleep(10)
    rcc = ReviewerCandidatesCard(self.getDriver())
    rcc.validate_styles(reviewer_login, paper_id)
    rcc.check_initial_population(reviewer_login, choice, reason)

  def test_core_delete_reviewer_candidate(self):
    """
    test_reviewer_candidates_task: Validates the submission of a recommended or opposed reviewer.
      Following submission deletes that submitted reviewer.
      Validates no submitted data present on the workflow card.
    :return: void function
    """
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat',
                        type_='generateCompleteApexData',
                        random_bit=True,
                        title='Reviewer Candidates Test'
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
    manuscript_page.click_task('review_candidates')
    time.sleep(2)
    rev_cand_task = ReviewerCandidatesTask(self.getDriver())
    time.sleep(1)
    rev_cand_task.delete_reviewer_cand_entry(random.choice(users))
    time.sleep(2)
    rev_cand_task.click_completion_button()
    rev_cand_task.check_for_flash_error()
    rev_cand_task.logout()

    # login as privileged user to validate the presentation of the data on the RC Card
    staff_user = random.choice(editorial_users)
    logging.info('Logging in as user: {0}'.format(['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    time.sleep(3)
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    time.sleep(3)
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    time.sleep(2)
    workflow_page.click_card('reviewer_candidates')
    time.sleep(10)
    rcc = ReviewerCandidatesCard(self.getDriver())
    rcc.check_no_entry()

  def test_core_reviewer_candidates_permissions(self):
    """
    test_reviewer_candidates_task: Validates the access permissions for the reviewer candidates task
      a Reviewer will never ever see a reviewer recommendations card
      an AE will always be able to view the reviewer recommendations card
      a paper Creator can view/edit the reviewer recommendations card
      a paper Collaborator can view/edit the reviewer recommendations card
      DONE inherently in the previous two tests Staff can view/edit the reviewer
        recommendations card
    :return: void function
    """
    pass

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
