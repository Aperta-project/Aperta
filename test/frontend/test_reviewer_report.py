#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates Reviewer Report card
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import reviewer_login, users, editorial_users
from frontend.common_test import CommonTest
from Cards.invite_reviewer_card import InviteReviewersCard
from Cards.reviewer_report_card import ReviewerReportCard
from Tasks.reviewer_report_task import ReviewerReportTask
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'sbassi@plos.org'


@MultiBrowserFixture
class ReviewerReportTest(CommonTest):
  """
  Validate the elements, styles, functions of the Reviewer Report task
  Need to validate both the research reviewer report and the front-matter only reviewer report
    Validate question content for each type
    Validate ordering in both edit and view (submitted) modes in the context of both the task view
      and the card view - ordering should not chnage between these modes.
    Validate styles for both reports in both edit and view mode in both contexts (task and card)
  """

  def _test_core_rev_rep_non_research_actions(self):
    """
    test_reviewer_report: Validates the elements, styles, roles and functions of the front-matter
      reviewer report.
    :return: None
    """
    logging.info('Test Reviewer Report::front_matter')
    current_path = os.getcwd()
    logging.info(current_path)
    logging.info('test_core_rev_rep_non_research_actions')
    # Create base data - new papers
    creator_user = random.choice(users)
    logging.info(creator_user)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Front-Matter-type', random_bit=True)
    dashboard_page.restore_timeout()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # Abbreviate the timeout for conversion success message
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    # Note: Request title to make sure the required page is loaded
    research_paper_id = manuscript_page.get_paper_short_doi_from_url()
    # Need to complete cards here
    manuscript_page.complete_task('Additional Information')
    manuscript_page.complete_task('Authors', author = creator_user)
    manuscript_page.complete_task('Figures')
    manuscript_page.complete_task('Supporting Info')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()

    editorial_user = random.choice(editorial_users)
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page._wait_for_element(
      dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(research_paper_id)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    workflow_page.click_card('invite_reviewers')
    invite_reviewers = InviteReviewersCard(self.getDriver())
    logging.info('Paper id is: {0}.'.format(research_paper_id))
    invite_reviewers.invite(reviewer_login)
    workflow_page.logout()

    # login as reviewer respond to invite
    dashboard_page = self.cas_login(email=reviewer_login['email'])
    dashboard_page.click_view_invites_button()

    ms_title = PgSQL().query('SELECT title from papers WHERE short_doi = %s;', (research_paper_id,))[0][0]
    ms_title = unicode(ms_title, encoding='utf-8', errors='strict')
    dashboard_page.accept_invitation(ms_title)
    dashboard_page._wait_for_element(dashboard_page._get(
      dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(research_paper_id)
    self._driver.navigated = True
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # watch to insert time here
    time.sleep(5)
    # screenshot
    self._driver.save_screenshot('108.png')
    assert manuscript_page.click_task('Review by')
    reviewer_report_task = ReviewerReportTask(self.getDriver())
    reviewer_report_task.validate_task_elements_styles(research_type=False)
    reviewer_report_task.validate_reviewer_report_edit_mode(research_type=False)
    outdata = manuscript_page.complete_task('Review by', click_override=True)
    logging.debug(outdata)
    validate_view_in_place = manuscript_page.get_random_bool()
    validate_view_in_place = False
    if validate_view_in_place:
      logging.info('Validating in task view')
      reviewer_report_task.validate_view_mode_report_in_task(outdata)
    else:
      logging.info('Validating in card view')
      manuscript_page.logout()
      # Then login as staff user and validate report in card view
      editorial_user = random.choice(editorial_users)
      logging.info(editorial_user)
      dashboard_page = self.cas_login(email=editorial_user['email'])
      dashboard_page._wait_for_element(
        dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
      dashboard_page.go_to_manuscript(research_paper_id)
      self._driver.navigated = True
      paper_viewer = ManuscriptViewerPage(self.getDriver())
      paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
      # go to wf
      paper_viewer.click_workflow_link()
      workflow_page = WorkflowPage(self.getDriver())
      workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
      card_title = 'Review by {0} (#1)'.format(reviewer_login['name'])
      workflow_page.click_card('review_by', card_title)
      reviewer_report_card = ReviewerReportCard(self.getDriver())
      reviewer_report_card.validate_reviewer_report(outdata, research_type=False)

  def test_core_rev_rep_research_actions(self):
    """
    test_reviewer_report: Validates the elements, styles, roles and functions of the research
      reviewer report.
    :return: None
    """
    logging.info('Test Reviewer Report::research')
    current_path = os.getcwd()
    logging.info(current_path)
    logging.info('test_core_rev_rep_research_actions')
    # Create base data - new papers
    creator_user = random.choice(users)
    logging.info(creator_user)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='NoCards', random_bit=True)
    dashboard_page.restore_timeout()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # Abbreviate the timeout for conversion success message
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    # Note: Request title to make sure the required page is loaded
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()

    editorial_user = random.choice(editorial_users)
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    ##paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    workflow_page.click_card('invite_reviewers')
    invite_reviewers = InviteReviewersCard(self.getDriver())
    logging.info('Paper short DOI is: {0}.'.format(short_doi))
    invite_reviewers.invite(reviewer_login)
    workflow_page.logout()

    # login as reviewer respond to invite
    dashboard_page = self.cas_login(email=reviewer_login['email'])
    dashboard_page.click_view_invites_button()
    ms_title = PgSQL().query('SELECT title from papers WHERE short_doi = %s;', (short_doi,))[0][0]
    ms_title = unicode(ms_title, encoding='utf-8', errors='strict')
    dashboard_page.accept_invitation(ms_title)
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    assert manuscript_page.click_task('Review by ')
    reviewer_report_task = ReviewerReportTask(self.getDriver())
    reviewer_report_task.validate_task_elements_styles()
    reviewer_report_task.validate_reviewer_report_edit_mode()
    outdata = manuscript_page.complete_task('Review by', click_override=True)
    validate_in = {True: 'task', False: 'card'}
    validate_view_in_place = manuscript_page.get_random_bool()
    logging.info('Validate in {}'.format(validate_in[validate_view_in_place]))
    validate_view_in_place = True
    dashboard_page.logout()
    if validate_view_in_place:
      logging.info(reviewer_login)
      dashboard_page = self.cas_login(email=reviewer_login['email'])
      dashboard_page.page_ready()
      dashboard_page.go_to_manuscript(short_doi)
      self._driver.navigated = True
      paper_viewer = ManuscriptViewerPage(self.getDriver())
      paper_viewer.page_ready()
      logging.info('Validating in task view')
      assert paper_viewer.click_task('Review by ')
      reviewer_report_task.validate_view_mode_report_in_task(outdata)
    else:
      logging.info('Validating in card view')
      # Then login as staff user and validate report in card view
      editorial_user = random.choice(editorial_users)
      logging.info(editorial_user)
      dashboard_page = self.cas_login(email=editorial_user['email'])
      dashboard_page.page_ready()
      dashboard_page.go_to_manuscript(short_doi)
      self._driver.navigated = True
      paper_viewer = ManuscriptViewerPage(self.getDriver())
      ##paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
      paper_viewer.page_ready()
      # go to wf
      paper_viewer.click_workflow_link()
      workflow_page = WorkflowPage(self.getDriver())
      workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
      workflow_page.click_card('review_by')
      reviewer_report_card = ReviewerReportCard(self.getDriver())
      reviewer_report_card.validate_reviewer_report(outdata)

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
