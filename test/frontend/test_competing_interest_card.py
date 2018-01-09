#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This test case validates style and function of Competing Interest Card
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import os
import random
import time

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users, handling_editor_login, academic_editor_login, staff_admin_login, \
  super_admin_login, prod_staff_login, pub_svcs_login, external_editorial_users
from frontend.Cards.competing_interest_card import CompetingInterestCard
from frontend.Tasks.competing_interest_task import CompetingInterestTask
from frontend.common_test import CommonTest
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.workflow_page import WorkflowPage

__author__ = 'gholmes@plos.org'



@MultiBrowserFixture
class CompetingInterestCardTest(CommonTest):
  """
  Validate the elements, styles, functions of the Competing Interest card
  """

  def test_smoke_ci_styles(self):
    """
    test_competing_interest_card: Validates the elements, styles of the Early Version task and
      card from new document creation through workflow view
    :return: void function
    """
    logging.info('Test Competing Version::styles')
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Competing Interest Test', journal='PLOS Wombat',
                        type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    short_doi = manuscript_page.get_short_doi()
    # figures
    manuscript_page.click_task('Competing Interests')
    ci_task = CompetingInterestTask(self.getDriver())
    ci_task.task_ready()
    ci_task.validate_styles()
    ci_task.logout()

    # login as privileged user to validate the presentation of the data on the CI Card
    staff_user = random.choice(editorial_users)
    logging.info('Logging in as user: {0}'.format(staff_user['name']))
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
    workflow_page.click_competing_interest_card()
    ci_card = CompetingInterestCard(self.getDriver())
    ci_card.card_ready()
    ci_card.validate_styles()

  def test_core_ci_selection(self):
    """
    test_competing_interect_card: Validates the selection state for ci
    :return: void function
    """
    logging.info('Competing::selection')
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Competing Interest', journal='PLOS Wombat',
                        type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    short_doi = manuscript_page.get_short_doi()
    # figures
    manuscript_page.click_task('Competing Interests')
    ci_task = CompetingInterestTask(self.getDriver())
    ci_task.task_ready()
    ci_task.complete_form('yes')
    ci_task.click_completion_button()
    ci_task.logout()

    # login as privileged user to validate the presentation of the data on the RC Card
    staff_user = random.choice(editorial_users)
    logging.info('Logging in as user: {0}'.format(staff_user['name']))
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
    workflow_page.click_competing_interest_card()
    ci_card = CompetingInterestCard(self.getDriver())
    ci_card.click_completion_button()
    ci_card.card_ready()
    ci_card.validate_state('yes')
    ci_task.complete_form('no')
    ci_card.validate_state('no')




if __name__ == '__main__':
  CommonTest._run_tests_randomly()