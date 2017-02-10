#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates style and function of the Supporting Information (SI) Card and Task
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted
    into frontend/assets/
"""
import logging
import os
import random
import time

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.Resources import docs, users, editorial_users
from frontend.common_test import CommonTest
##from frontend.Tasks.supporting_information_task import SITask
from frontend.Cards.ad_hoc_author_card import AHAuthorCard
from frontend.Cards.ad_hoc_editor_card import AHEditorCard
from frontend.Cards.ad_hoc_reviewer_card import AHReviewerCard
from frontend.Cards.ad_hoc_staff_card import AHStaffCard
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

from loremipsum import generate_paragraph

__author__ = 'sbassi@plos.org'


@MultiBrowserFixture
class AdHocCardAuthorTest(CommonTest):
  """
  Validate the elements, styles, functions of the Ad-Hoc Card
  """

  def _test_ad_hoc_author_card_styles(self):
    """
    test_ad_hoc_author_card_styles: Validates the elements, styles Ad Hoc card
    :return: None
    """
    creator_user = random.choice(users)
    logging.info('Login as {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_url = manuscript_page.get_current_url()
    short_doi = manuscript_page.get_short_doi()
    logging.info('The paper URL of this newly created paper is: {0}'.format(paper_url))
    manuscript_page.logout()
    # Log in as Editorial User
    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    # go to paper
    self._driver.get(paper_url)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    manuscript_page.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    if not workflow_page.is_card('Ad-hoc for Authors'):
      workflow_page.add_card('Ad-hoc for Authors')
    workflow_page.click_ad_hoc_authors_card()
    ad_hoc_authors_card = AHAuthorCard(self._driver)
    ad_hoc_authors_card.validate_card_elements_styles(short_doi, 'Author')
    return None

  def test_ad_hoc_card_styles(self):
    """
    test_ad_hoc_author_card_styles: Validates the elements, styles Ad Hoc card
    :return: None
    """
    creator_user = random.choice(users)
    logging.info('Login as {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    paper_url = manuscript_page.get_current_url()
    short_doi = manuscript_page.get_short_doi()
    logging.info('The paper URL of this newly created paper is: {0}'.format(paper_url))
    manuscript_page.logout()
    # Log in as Editorial User
    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    # go to paper
    self._driver.get(paper_url)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    manuscript_page.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    ad_hoc_user = random.choice(('Authors', 'Editors', 'Reviewers', 'Staff Only'))
    logging.info('Ad Hoc card for: {0}'.format(ad_hoc_user))
    if not workflow_page.is_card('Ad-hoc for {0}'.format(ad_hoc_user)):
      workflow_page.add_card('Ad-hoc for {0}'.format(ad_hoc_user))
    if ad_hoc_user == 'Authors':
      workflow_page.click_ad_hoc_authors_card()
      ad_hoc_card = AHAuthorCard(self._driver)
    elif ad_hoc_user == 'Editors':
      workflow_page.click_ad_hoc_editor_card()
      ad_hoc_card = AHEditorCard(self._driver)
    elif ad_hoc_user == 'Reviewers':
      workflow_page.click_ad_hoc_reviewer_card()
      ad_hoc_card = AHReviewerCard(self._driver)
    elif ad_hoc_user == 'Staff Only':
      workflow_page.click_ad_hoc_staff_card()
      ad_hoc_card = AHStaffCard(self._driver)
    ad_hoc_card.validate_card_elements_styles(short_doi, ad_hoc_user)
    ad_hoc_card._get(ad_hoc_card._add_btn).click()
    controller = random.choice(('check', 'input_text', 'paragraph', 'email', 'file_upload'))
    logging.info('Testing {0} controller'.format(controller))
    ad_hoc_card.validate_controller_styles(controller)
    return None


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
