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
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
from Cards.figures_card import FiguresCard
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage
from Tasks.figures_task import FiguresTask

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class FigureTaskTest(CommonTest):
  """
  Validate the elements, styles, functions of the Figures Card
  """

  def test_smoke_figures_task_styles(self):
    """
    test_figure_task: Validates the elements and styles of the figures task
    :return: void function
    """
    logging.info('Test Figures::styles')
    current_path = os.getcwd()
    logging.info(current_path)
    creator = random.choice(users)
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.page_ready()
    logging.info('Calling Create new Article')
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat',
                        type_='Images+InitialDecision')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.close_infobox()
    manuscript_page.click_task('Figures')
    manuscript_page.get_short_doi()
    figures_task = FiguresTask(self.getDriver())
    figures_task.task_ready()
    # Need at least one figure in place to check all the styles
    figures_task.upload_figure()
    # It is necessary to provide a lengthy wait for upload and processing of the image
    time.sleep(10)
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
    logging.info('Test Figures::upload')
    current_path = os.getcwd()
    logging.info(current_path)
    creator = random.choice(users)
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.page_ready()
    logging.info('Calling Create new Article')
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Images+InitialDecision')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.close_infobox()
    manuscript_page.get_short_doi()
    manuscript_page.click_task('Figures')
    paper_url = manuscript_page.get_current_url()
    figures_task = FiguresTask(self.getDriver())
    figures_task.check_question()
    figures_list = figures_task.upload_figure(iterations=4)
    # It is necessary to provide a lengthy wait for upload and processing of the image
    time.sleep(10)
    figures_list.sort(reverse=True)
    logging.info(figures_list)
    figures_task.logout()

    # Login as a privileged user to check the Card view of the figures task for uploaded files
    internal_staff = random.choice(editorial_users)
    logging.info(internal_staff['name'])
    dashboard_page = self.cas_login(email=internal_staff['email'])
    dashboard_page.page_ready()
    self._driver.get(paper_url)
    self._driver.navigated = True
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    manuscript_page.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('figures')
    figures_card = FiguresCard(self.getDriver())
    figures_card.card_ready()
    figures_card.validate_figure_presence(figures_list)
    figures_card.logout()

  def test_core_figures_task_replace(self):
    """
    test_figure_task: Validates the replacement function of the figures task
    :return: void function
    """
    logging.info('Test Figures::replace')
    creator = random.choice(users)
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.page_ready()
    logging.info('Calling Create new Article')
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Images+InitialDecision')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.close_infobox()
    manuscript_page.get_short_doi()
    manuscript_page.click_task('Figures')
    figures_task = FiguresTask(self.getDriver())
    figures_task.task_ready()
    figures_task.check_question()
    figures_task.upload_figure(figure2send='frontend/assets/imgs/figure1_tiff_lzw.tiff')
    # Need to allot a good amount of time here for figure upload, storage and thumbnail processing
    #  Have had rare failures at 22s
    time.sleep(25)
    figures_list = figures_task.replace_figure(figure2replace='figure1_tiff_lzw.tiff',
                                               replacement_figure='frontend/assets/imgs/figure2_tiff_lzw.tiff')
    logging.info(figures_list)
    figures_task.validate_figure_presence(figures_list)
    figures_task.logout()

  def test_core_figures_task_delete(self):
    """
    test_figure_task: Validates the delete function of the figures task
    :return: void function
    """
    logging.info('Test Figures::delete')
    current_path = os.getcwd()
    logging.info(current_path)
    creator = random.choice(users)
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.page_ready()
    logging.info('Calling Create new Article')
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Images+InitialDecision')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.close_infobox()
    paper_url = manuscript_page.get_current_url()
    manuscript_page.click_task('Figures')
    figures_task = FiguresTask(self.getDriver())
    figures_task.task_ready()
    figures_task.check_question()
    figures_list = figures_task.upload_figure()
    # Need to allot a good amount of time here for figure upload, storage and thumbnail processing
    #  Have had rare failures at 20s
    time.sleep(22)
    figures_task.delete_figure(figures_list)
    figures_task.validate_figure_not_present(figures_list)

  def test_core_figures_task_download(self):
    """
    test_figure_task: Validates the download function of the figures task
    :return: void function
    """
    logging.info('Test Figures::download')
    current_path = os.getcwd()
    logging.info(current_path)
    creator = random.choice(users)
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.page_ready()
    logging.info('Calling Create new Article')
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Images+InitialDecision')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    manuscript_page.close_infobox()
    manuscript_page.click_task('Figures')
    paper_url = manuscript_page.get_current_url()
    paper_id = paper_url.split('/')[-1].split('?')[0]
    figures_task = FiguresTask(self.getDriver())
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    figures_task.task_ready()
    figures_task.check_question()
    figures_list = figures_task.upload_figure()
    # Need to allot a good amount of time here for figure upload, storage and thumbnail processing
    #  Have had rare failures at 20s
    time.sleep(22)
    figures_task.download_figure(figures_list)
    # Need to do some sort of validation on the downloaded file.
    time.sleep(5)

  def test_core_figures_task_edit_reorder(self):
    """
    test_figure_task: Validates the edit function of the figures task, including re-ordering
    :return: void function
    """
    logging.info('Test Figures::edit_reorder')
    current_path = os.getcwd()
    logging.info(current_path)
    creator = random.choice(users)
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    logging.info('Calling Create new Article')
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Images+InitialDecision')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=45)
    manuscript_page.close_infobox()
    manuscript_page.click_task('Figures')
    paper_url = manuscript_page.get_current_url()
    paper_id = paper_url.split('/')[-1].split('?')[0]
    figures_task = FiguresTask(self.getDriver())
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    figures_task.check_question()
    figures_list = figures_task.upload_figure('frontend/assets/imgs/ardea_herodias_lzw_sm.tiff')
    # It is necessary to provide a lengthy wait for upload and processing of the image
    next_figure = figures_task.upload_figure('frontend/assets/imgs/figure2_tiff_lzw.tiff')
    figures_list.append(next_figure)
    logging.info(figures_list)
    figures_task.edit_figure(figures_list[0])
    figures_task.logout()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
