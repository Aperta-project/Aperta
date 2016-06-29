#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This functional test case validates the figure task as presented to the author.
The author should be able to:
    a) upload a figure
    b) replace a figure
    c) download a figure
    d) delete a figure
    e) add/edit a figure label
      i) labels must be unique
    f) change figure order
      i) figures auto-order based on figure label
      ii) figures with undiscernable labels are placed last
    g) tag an image as the striking image
    h) hover over an image to see the edit and delete icons in grey
      i) hovering over the grey icons turns them green
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted into
    frontend/assets/
"""
import logging
import random
import time

from selenium.webdriver.common.by import By

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import users, editorial_users
from Cards.figures_card import FiguresCard
from Tasks.figures_task import FiguresTask
from frontend.common_test import CommonTest
from Pages.authenticated_page import application_typeface
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class WithdrawManuscriptTest(CommonTest):
  """
  Validate the elements, styles, functions of the Figures Card
  """

  def test_smoke_figures_task_styles(self):
    """
    test_figure_task: Validates the elements and styles of the figures task
    :return: void function
    """
    creator = random.choice(users)
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    logging.info('Calling Create new Article')
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Images+InitialDecision')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=30)
    manuscript_page.close_infobox()
    manuscript_page.click_task('figures')
    paper_url = manuscript_page.get_current_url()
    paper_id = paper_url.split('/')[-1].split('?')[0]
    figures_task = FiguresTask(self.getDriver())
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    # Need at least one figure in place to check all the styles
    figures_task.upload_figure()
    figures_task.click_completion_button()
    time.sleep(1)
    figures_task.check_for_flash_error()
    state = figures_task.completed_state()
    assert state, state
    figures_task.click_completion_button()
    time.sleep(1)
    figures_task.check_for_flash_error()
    state = figures_task.completed_state()
    assert not state, not state
    time.sleep(2)
    # Doing this late in the test to give everything its best chance to be done processing
    figures_task.validate_styles()
    figures_task.logout()

  def test_core_figures_task_upload(self):
    """
    test_figure_task: Validates the upload function of the figures task
    :return: void function
    """
    creator = random.choice(users)
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    logging.info('Calling Create new Article')
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Images+InitialDecision')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=30)
    manuscript_page.close_infobox()
    manuscript_page.click_task('figures')
    paper_url = manuscript_page.get_current_url()
    paper_id = paper_url.split('/')[-1].split('?')[0]
    figures_task = FiguresTask(self.getDriver())
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    figures_task.check_question()
    figures_list = figures_task.upload_figure(iterations=4)
    figures_list.sort(reverse=True)
    logging.info(figures_list)
    figures_task.logout()

    # Login as a privileged user to check the Card view of the figures task for uploaded files
    internal_staff = random.choice(editorial_users)
    logging.info(internal_staff['name'])
    dashboard_page = self.cas_login(email=internal_staff['email'])
    self._driver.get(paper_url)
    self._driver.navigated = True
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # Give a little time for the page to draw
    time.sleep(5)
    manuscript_page.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the workflow page to load and for the elements to attach to DOM,
    #   otherwise failures
    time.sleep(10)
    workflow_page.click_card('figures')
    # It takes a bit for the images to attach to the DOM after drawing the overlay in CI
    time.sleep(7)
    figures_card = FiguresCard(self.getDriver())
    figures_card.validate_figure_presence(figures_list)
    figures_card.logout()

  def test_core_figures_task_replace(self):
    """
    test_figure_task: Validates the replacement function of the figures task
    :return: void function
    """
    creator = random.choice(users)
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    logging.info('Calling Create new Article')
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Images+InitialDecision')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=30)
    manuscript_page.close_infobox()
    manuscript_page.click_task('figures')
    paper_url = manuscript_page.get_current_url()
    paper_id = paper_url.split('/')[-1].split('?')[0]
    figures_task = FiguresTask(self.getDriver())
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    figures_task.check_question()
    figures_list = figures_task.upload_figure()
    figures_task.logout()

    self._login_to_figs(creator)
    time.sleep(15)
    figures_task.replace_figure(figures_list[0])
    time.sleep(10)
    figures_task.logout()
    #
    # # Login as a privileged user to check the Card view of the figures task for uploaded files
    # internal_staff = random.choice(editorial_users)
    # logging.info(internal_staff['name'])
    # dashboard_page = self.cas_login(email=internal_staff['email'])
    # self._driver.get(paper_url)
    # self._driver.navigated = True
    # manuscript_page = ManuscriptViewerPage(self.getDriver())
    # # Give a little time for the page to draw
    # time.sleep(5)
    # manuscript_page.click_workflow_link()
    # workflow_page = WorkflowPage(self.getDriver())
    # # Need to provide time for the workflow page to load and for the elements to attach to DOM,
    # #   otherwise failures
    # time.sleep(10)
    # workflow_page.click_card('figures')
    # # It takes a bit for the images to attach to the DOM after drawing the overlay in CI
    # time.sleep(7)
    # figures_card = FiguresCard(self.getDriver())
    # figures_card.validate_figure_presence(figures_list)
    # figures_card.logout()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
