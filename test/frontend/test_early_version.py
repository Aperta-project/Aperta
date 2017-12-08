#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates the early version task and card.
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted into
    frontend/assets/
This test also requires a new mmt in PLOS Wombat: generateCompleteApexData
"""

import logging
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
from .Cards.early_version_card import EarlyVersionCard
from frontend.common_test import CommonTest
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.workflow_page import WorkflowPage
from .Tasks.early_version_task import EarlyVersionTask

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class EarlyVersionTaskTest(CommonTest):
  """
  1. Author can opt out or opt in (default choice) to early version
  """

  def test_smoke_ev_styles(self):
    """
    test_early_article_posting: Validates the elements, styles of the Early Version task and
      card from new document creation through workflow view
    :return: void function
    """
    logging.info('Test Early Version::styles')
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Early Version Test', journal='PLOS Wombat',
                        type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    short_doi = manuscript_page.get_short_doi()
    # figures
    manuscript_page.click_task('Early Version')
    ev_task = EarlyVersionTask(self.getDriver())
    ev_task.task_ready()
    ev_task.validate_styles()
    ev_task.click_completion_button()
    ev_task.logout()

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
    workflow_page.click_card('early_version')
    ev_card = EarlyVersionCard(self.getDriver())
    ev_card.card_ready()
    ev_card.validate_styles()

  def test_core_ev_selection(self):
    """
    test_early_article_posting: Validates the selection state for ev
    :return: void function
    """
    logging.info('Test Early Version::selection')
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Early Version Test', journal='PLOS Wombat',
                        type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    short_doi = manuscript_page.get_short_doi()
    # figures
    manuscript_page.click_task('Early Version')
    ev_task = EarlyVersionTask(self.getDriver())
    ev_task.task_ready()
    selection_state = ev_task.complete_form()
    ev_task.click_completion_button()
    ev_task.logout()

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
    workflow_page.click_card('early_version')
    ev_card = EarlyVersionCard(self.getDriver())
    ev_card.card_ready()
    ev_card.validate_state(selection_state=selection_state)

if __name__ == '__main__':
  CommonTest.run_tests_randomly()
