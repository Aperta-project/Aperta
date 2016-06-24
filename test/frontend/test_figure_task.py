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

  def _go_to_figures_task(self):
    """Go to the addl info task"""
    dashboard = self.cas_login()
    logging.info('Calling Create new Article')
    dashboard.click_create_new_submission_button()
    article_name = self.create_article(journal='PLOS Wombat', type_='Images+InitialDecision')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=15)
    manuscript_page.click_task('figures')
    paper_url = manuscript_page.get_current_url()
    return FiguresTask(self.getDriver()), article_name, paper_url

  def test_smoke_figures_card(self):
    """
    test_figure_task: Validates the elements and styles of the figures task
    :return: void function
    """
    figures_task, title, paper_url = self._go_to_figures_task()
    paper_id = paper_url.split('/')[-1].split('?')[0]
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    figures_task.validate_styles()
    figures_task.check_question()
    for i in range(0, 4):
      figures_task.upload_figure()
      time.sleep(2)
    figures_task.logout()

    # Login as a privileged user to check the Card view of the figures task
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
    time.sleep(10)


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
