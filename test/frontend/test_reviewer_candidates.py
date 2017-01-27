#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates the reviewer candidates task and card.
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted into
    frontend/assets/
This test also requires a new mmt in PLOS Wombat: OnlyReviewerCandidates
"""

import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import users, reviewer_login, academic_editor_login, editorial_users
from Cards.invite_reviewer_card import InviteReviewersCard
from Cards.invite_ae_card import InviteAECard
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
    logging.info('Test Reviewer Candidates::styles')
    current_path = os.getcwd()
    logging.info(current_path)
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Reviewer Candidates Test', journal='PLOS Wombat',
                        type_='generateCompleteApexData', random_bit=True)
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    dashboard_page.restore_timeout()
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    # Note: Request title to make sure the required page is loaded
    paper_id = manuscript_page.get_paper_short_doi_from_url()
    time.sleep(2)
    # figures
    manuscript_page.click_task('Reviewer Candidates')
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
    logging.info('Test Reviewer Candidates::add_candidate')
    current_path = os.getcwd()
    logging.info(current_path)
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Reviewer Candidates Test', journal='PLOS Wombat',
                        type_='generateCompleteApexData', random_bit=True)
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    dashboard_page.restore_timeout()
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    # Note: Request title to make sure the required page is loaded
    paper_id = manuscript_page.get_paper_short_doi_from_url()
    time.sleep(2)
    # figures
    manuscript_page.click_task('Reviewer Candidates')
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
    logging.info('Test Reviewer Candidates::delete_candidate')
    current_path = os.getcwd()
    logging.info(current_path)
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Reviewer Candidates Test', journal='PLOS Wombat',
                        type_='generateCompleteApexData', random_bit=True)
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    dashboard_page.restore_timeout()
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    # Note: Request title to make sure the required page is loaded
    paper_id = manuscript_page.get_paper_short_doi_from_url()
    time.sleep(2)
    # figures
    manuscript_page.click_task('Reviewer Candidates')
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
    time.sleep(2)
    rcc = ReviewerCandidatesCard(self.getDriver())
    rcc.check_no_entry()

  def test_core_reviewer_candidates_permissions(self):
    """
    test_reviewer_candidates_task: Validates the access permissions for the reviewer candidates task
      a Reviewer will never ever see a reviewer recommendations card
      an AE will always be able to view the reviewer recommendations card
      inherently in previous two tests a paper Creator can view/edit the reviewer
        recommendations card
      inherently in the previous two tests Staff can view/edit the reviewer
        recommendations card
    :return: void function
    """
    # TODO (collaborators are not currently enabled) a paper Collaborator can view/edit the
    #   reviewer recommendations card.
    logging.info('Test Reviewer Candidates::permissions')
    current_path = os.getcwd()
    logging.info(current_path)
    #  First check for required initial data
    mmts = []
    journal_id = PgSQL().query("SELECT id FROM journals j WHERE j.name = 'PLOS Wombat';")[0][0]
    mmt_tuples = PgSQL().query('SELECT paper_type '
                               'FROM manuscript_manager_templates '
                               'WHERE journal_id = %s;', (journal_id,))
    for mmt_tuple in mmt_tuples:
      mmts.append(mmt_tuple[0])
    if 'OnlyReviewerCandidates' not in mmts:
      logging.info('Required Data not present, aborting')
      raise(StandardError, 'Required seed data not present: '
                           'PLOS Wombat journal, Only ReviewerCandidates mmt')
    else:
      logging.info('Required Data IS present, continuing...')

    # Users logs in and make a submission
    creator_user = random.choice(users)
    logging.info('Logging in as {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Reviewer Candidates Test', journal='PLOS Wombat',
                        type_='OnlyReviewerCandidates', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    manuscript_page.click_task('Reviewer Candidates')
    reviewer = random.choice(users)
    logging.info(u'Reviewer is: {0}'.format(reviewer['name']))
    rev_cand_task = ReviewerCandidatesTask(self.getDriver())
    rev_cand_task.complete_reviewer_cand_form(reviewer)
    rev_cand_task.click_completion_button()
    manuscript_page.check_for_flash_error()
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_submit_overlay()
    manuscript_page.page_ready()
    manuscript_page.logout()

    # login as privileged user to invite an AE and a Reviewer
    staff_user = random.choice(editorial_users)
    dashboard_page = self.cas_login(email=staff_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('invite_reviewers')
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.card_ready()
    invite_reviewers.invite(reviewer_login)
    workflow_page.page_ready()
    workflow_page.click_invite_ae_card()
    invite_ae_card = InviteAECard(self.getDriver())
    invite_ae_card.card_ready()
    invite_ae_card.invite(academic_editor_login)
    workflow_page.page_ready()
    # Now set the reviewer candidates card to incomplete and set the manuscript editable
    #   this is necessary to test the absence of edit permissions for the AE user.
    workflow_page.click_card('reviewer_candidates')
    rev_cand_card = ReviewerCandidatesCard(self.getDriver())
    rev_cand_card.card_ready()
    rev_cand_card.click_completion_button()
    rev_cand_card.click_close_button()
    rev_cand_card.check_for_flash_error()
    workflow_page.set_editable()
    workflow_page.check_for_flash_error()
    workflow_page.logout()

    # Login as Reviewer and accept invitation
    dashboard_page = self.cas_login(email=reviewer_login['email'])
    dashboard_page.page_ready()
    dashboard_page.click_view_invitations()
    dashboard_page.accept_all_invitations()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    rc_task = paper_viewer.is_task_present('Reviewer Candidates')
    assert not rc_task
    paper_viewer.logout()

    # Login as AE and accept invitation
    dashboard_page = self.cas_login(email=academic_editor_login['email'])
    dashboard_page.page_ready()
    dashboard_page.click_view_invitations()
    dashboard_page.accept_all_invitations()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    rc_task = paper_viewer.is_task_present('Reviewer Candidates')
    assert rc_task
    logging.info('Reviewer Candidates task is present for AE')
    paper_viewer.click_task('Reviewer Candidates')
    rev_cand_task = ReviewerCandidatesTask(self.getDriver())
    # Note that one cannot use the normal task ready method here because we suppress the completion
    #   button when the editing permission is disabled. So the dread sleep...
    time.sleep(2)
    editable = rev_cand_task.assert_add_new_cand_btn_present()
    assert not editable

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
