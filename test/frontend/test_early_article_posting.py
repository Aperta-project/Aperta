#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates the early article posting task and card.
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted into
    frontend/assets/
This test also requires a new mmt in PLOS Wombat: generateCompleteApexData
"""

import logging
import os
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
from Cards.early_article_posting_card import EarlyArticlePostingCard
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage
from Tasks.early_article_posting import EarlyArticlePostingTask

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class EarlyArticlePostingTaskTest(CommonTest):
  """
  1. Author can opt out or opt in (default choice) to early article posting
  """

  def test_smoke_eap_styles(self):
    """
    test_early_article_posting: Validates the elements, styles of the Early Article Posting task and
      card from new document creation through workflow view
    :return: void function
    """
    logging.info('Test Early Article Posting::styles')
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Early Article Posting Test', journal='PLOS Wombat',
                        type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_id = manuscript_page.get_paper_id_from_url()
    # figures
    manuscript_page.click_task('early_article_posting')
    eap_task = EarlyArticlePostingTask(self.getDriver())
    eap_task.task_ready()
    eap_task.validate_styles()
    eap_task.click_completion_button()
    eap_task.logout()

    # login as privileged user to validate the presentation of the data on the RC Card
    staff_user = random.choice(editorial_users)
    logging.info('Logging in as user: {0}'.format(['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('early_article_posting')
    eap_card = EarlyArticlePostingCard(self.getDriver())
    eap_card.card_ready()
    eap_card.validate_styles()

  def test_core_eap_selection(self):
    """
    test_early_article_posting: Validates the selection state for eap
    :return: void function
    """
    logging.info('Test Early Article Posting::selection')
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Early Article Posting Test', journal='PLOS Wombat',
                        type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_id = manuscript_page.get_paper_id_from_url()
    # figures
    manuscript_page.click_task('early_article_posting')
    eap_task = EarlyArticlePostingTask(self.getDriver())
    eap_task.task_ready()
    selection_state = eap_task.complete_form()
    eap_task.click_completion_button()
    eap_task.logout()

    # login as privileged user to validate the presentation of the data on the RC Card
    staff_user = random.choice(editorial_users)
    logging.info('Logging in as user: {0}'.format(staff_user['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(paper_id)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('early_article_posting')
    eap_card = EarlyArticlePostingCard(self.getDriver())
    eap_card.card_ready()
    eap_card.validate_state(selection_state=selection_state)

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
