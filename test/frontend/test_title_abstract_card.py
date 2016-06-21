#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Title and Abstract Card
"""
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
from Cards.title_abstract_card import TitleAbstractCard
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class TitleAbstractTest(CommonTest):
  """
  Tests the UI, styles, and functions, editing and saved display of the Title and Abstract Card
    of the workflow page. This card doesn't appear elsewhere.
  """
  def test_smoke_components_styles(self):
    creator = random.choice(users)
    journal = 'PLOS Wombat'
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    # Create paper
    dashboard_page.click_create_new_submission_button()
    time.sleep(.5)
    paper_type = 'NoCards'
    logging.info('Creating Article in {0} of type {1}'.format(journal, paper_type))
    self.create_article(title='Testing Discussion Forum notifications',
                        journal=journal,
                        type_=paper_type,
                        random_bit=True,
                        )
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # check for flash message
    paper_viewer.validate_ihat_conversions_success(timeout=15)
    paper_id = paper_viewer.get_current_url().split('/')[-1]
    paper_id = paper_id.split('?')[0] if '?' in paper_id else paper_id
    logging.info("Assigned paper id: {0}".format(paper_id))
    paper_viewer.click_submit_btn()
    paper_viewer.confirm_submit_btn()
    paper_viewer.close_submit_overlay()
    # logout
    paper_viewer.logout()
    # log as editor - validate T&A Card
    staff_user = random.choice(editorial_users)
    logging.info('Logging in as user: {0}'.format(['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    time.sleep(2)
    workflow_page.click_card('title_and_abstract')
    time.sleep(3)
    title_abstract = TitleAbstractCard(self.getDriver())
    title_abstract.validate_card_header(paper_id)
    title_abstract.validate_common_elements_styles()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
