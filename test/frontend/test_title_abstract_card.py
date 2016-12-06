#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Title and Abstract Card
"""
import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
from Cards.title_abstract_card import TitleAbstractCard
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage
from Tasks.upload_manuscript_task import UploadManuscriptTask

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class TitleAbstractTest(CommonTest):
  """
  Tests the UI, styles, and functions, editing and saved display of the Title and Abstract Card
    of the workflow page. This card doesn't appear elsewhere.
  """
  def test_smoke_components_styles(self):
    """
    test_title_abstract_card: Validate components and styles of the Title and Abstract card
    :return: void function
    """
    logging.info('Test Title Abstract Card::components_styles')
    current_path = os.getcwd()
    logging.info(current_path)
    creator = random.choice(users)
    journal = 'PLOS Wombat'
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.page_ready()
    # Create paper
    dashboard_page.click_create_new_submission_button()
    dashboard_page._wait_for_element(dashboard_page._get(dashboard_page._cns_paper_type_chooser))
    paper_type = 'NoCards'
    logging.info('Creating Article in {0} of type {1}'.format(journal, paper_type))
    self.create_article(title='Testing Title and Abstract Card', journal=journal, type_=paper_type,
                        random_bit=True)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    short_doi = paper_viewer.get_short_doi()
    paper_viewer.logout()

    # log as editor - validate T&A Card
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
    workflow_page.click_card('title_and_abstract')
    title_abstract = TitleAbstractCard(self.getDriver())
    title_abstract._wait_for_element(title_abstract._get(title_abstract._abstract_input))
    title_abstract.validate_card_header(short_doi)
    title_abstract.validate_styles()

  def test_core_functions(self):
    """
    test_title_abstract_card: Validate extraction of data from db into card, reset of card state on
      re-upload
    :return: void function
    """
    logging.info('Test Title Abstract Card::function')
    current_path = os.getcwd()
    logging.info(current_path)
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
    self.create_article(title='Testing Title and Abstract Card', journal=journal, type_=paper_type,
                        random_bit=True)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # check for flash message
    paper_viewer.validate_ihat_conversions_success(timeout=45)
    # Need to wait for url to update
    count = 0
    short_doi = paper_viewer.get_current_url().split('/')[-1]
    while not short_doi:
      if count > 60:
        raise(StandardError, 'Short doi is not updated after a minute, aborting')
      time.sleep(1)
      short_doi = paper_viewer.get_current_url().split('/')[-1]
      count += 1
    short_doi = short_doi.split('?')[0] if '?' in short_doi else short_doi
    logging.info("Assigned paper short doi: {0}".format(short_doi))
    paper_viewer.logout()

    # log as editor - validate T&A Card
    staff_user = random.choice(editorial_users)
    logging.info('Logging in as user: {0}'.format(staff_user['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    dashboard_page._wait_for_element(
        dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    workflow_page.click_card('title_and_abstract')
    title_abstract = TitleAbstractCard(self.getDriver())
    title_abstract._wait_for_element(title_abstract._get(title_abstract._abstract_input))
    title_abstract.check_initial_population(short_doi)
    title_abstract.click_completion_button()
    title_abstract.click_close_button()
    title_abstract.logout()

    # log back in as author to re-upload MS
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page._wait_for_element(
        dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._upload_manu_task))
    paper_viewer.click_task('upload_manuscript')
    upms = UploadManuscriptTask(self.getDriver())
    upms._wait_for_element(upms._get(upms._completion_button))
    upms.click_completion_button()
    upms._wait_for_element(upms._get(upms._upload_manuscript_btn))
    upms.upload_manuscript()
    upms.validate_ihat_conversions_success(timeout=45)
    upms.check_for_flash_error()
    upms.logout()

    # log back in as editor to validate T&A card state reset
    staff_user = random.choice(editorial_users)
    logging.info('Logging in as user: {0}'.format(['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    dashboard_page._wait_for_element(
        dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn))
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    workflow_page.click_card('title_and_abstract')
    title_abstract = TitleAbstractCard(self.getDriver())
    title_abstract._wait_for_element(title_abstract._get(title_abstract._abstract_input))
    ta_state = title_abstract.completed_state()
    if ta_state:
      raise (AssertionError, 'Title and Abstract card state not reset on re-upload of manuscript')
    title_abstract.click_completion_button()
    new_ta_state = title_abstract.completed_state()
    # I don't see a non-rococo way to avoid this one
    time.sleep(1)
    if not new_ta_state:
      raise (AssertionError, 'Title and Abstract card state not in completed state')

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
