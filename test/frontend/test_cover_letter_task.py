#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users
from frontend.Tasks.cover_letter_task import CoverLetterTask
from Pages.manuscript_viewer import ManuscriptViewerPage
from frontend.common_test import CommonTest

"""
This test case validates the Cover Letter Task.
"""
__author__ = 'ivieira@plos.org'


@MultiBrowserFixture
class CoverLetterTaskTest(CommonTest):
  """
  Self imposed AC:
     - validate tasks elements and styles
     - validate the file upload actions (upload, download, replace, delete)
     - validate the textarea text input
  """

  def test_smoke_validate_components_styles(self):
    """
    test_smoke_validate_components_styles: Validates the elements, styles and functions for the cover letter task
    :return: void function
    """
    logging.info('Test Cover Letter Task::components_styles')
    current_path = os.getcwd()
    logging.info(current_path)
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research')
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(10)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('Cover Letter')
    cover_letter_task = CoverLetterTask(self.getDriver())
    cover_letter_task.validate_styles()

  def test_cover_letter_file_upload(self):
    """
    test_cover_letterfile__upload: Tests the cover letter file upload
    :return: void function
    """
    logging.info('Test Cover Letter Task::letter_file_upload')
    current_path = os.getcwd()
    logging.info(current_path)
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research')
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(10)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('Cover Letter')
    cover_letter_task = CoverLetterTask(self.getDriver())
    cover_letter_task.upload_letter()
    cover_letter_task.click_completion_button()

  def test_cover_letter_file_replace(self):
    """
    test_cover_letter_file_replace: Tests the replacing of an uploaded cover letter file
    :return: void function
    """
    logging.info('Test Cover Letter Task::letter_file_replace')
    current_path = os.getcwd()
    logging.info(current_path)
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research')
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(10)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('Cover Letter')
    cover_letter_task = CoverLetterTask(self.getDriver())
    cover_letter_task.replace_letter()

  def test_cover_letter_file_delete(self):
    """
    test_cover_letter_file_delete: Tests the deleting of an uploaded cover letter file
    :return: void function
    """
    logging.info('Test Cover Letter Task::letter_file_delete')
    current_path = os.getcwd()
    logging.info(current_path)
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research')
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(10)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('Cover Letter')
    cover_letter_task = CoverLetterTask(self.getDriver())
    cover_letter_task.remove_letter()

  def test_cover_letter_file_download(self):
    """
    test_cover_letter_file_delete: Tests the downloading of an uploaded cover letter file
    :return: void function
    """
    logging.info('Test Cover Letter Task::letter_file_download')
    current_path = os.getcwd()
    logging.info(current_path)
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research')
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(10)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('Cover Letter')
    cover_letter_task = CoverLetterTask(self.getDriver())
    cover_letter_task.download_letter()

  def test_cover_letter_textarea(self):
    """
    test_cover_letter_textarea: Tests the cover letter textarea input
    :return: void function
    """
    logging.info('Test Cover Letter Task::letter_textarea')
    current_path = os.getcwd()
    logging.info(current_path)
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research')
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(10)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('Cover Letter')
    cover_letter_task = CoverLetterTask(self.getDriver())
    cover_letter_task.validate_letter_textarea()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
