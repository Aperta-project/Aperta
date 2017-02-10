#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Cover Letter Task.
"""

import logging
import random

import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
from frontend.Cards.cover_letter_card import CoverLetterCard
from frontend.Pages.workflow_page import WorkflowPage
from frontend.Tasks.cover_letter_task import CoverLetterTask
from Pages.manuscript_viewer import ManuscriptViewerPage
from frontend.common_test import CommonTest

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
    test_smoke_validate_components_styles: Validates the elements, styles and functions for the
      cover letter task and card
    :return: void function
    """
    logging.info('Test Cover Letter Task::components_styles')
    user_type = random.choice(users)
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    short_doi = manuscript_page.get_short_doi()
    manuscript_page.click_task('Cover Letter')

    # Test task styles
    cover_letter_task = CoverLetterTask(self.getDriver())
    cover_letter_task.task_ready()
    cover_letter_task.validate_styles()
    # Mark task as complete
    cover_letter_task.click_completion_button()
    cover_letter_task.logout()

    # Test card styles and activity feed
    staff_user = random.choice(editorial_users)
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

    # Test task completion on activity feed
    workflow_page.click_recent_activity_link()
    workflow_page.validate_recent_activity_entry('Cover Letter card was '
                                                 'marked as complete',
                                                 user_type['name'])
    workflow_page.click_close_overlay()

    workflow_page.click_card('cover_letter')
    cover_letter_card = CoverLetterCard(self.getDriver())
    cover_letter_card.card_ready()
    # cover_letter_card.validate_common_elements_styles(short_doi)
    cover_letter_card.validate_styles()
    # Mark card as incomplete
    cover_letter_card.click_completion_button()
    cover_letter_card.click_close_button()
    # Wait for modal transition
    time.sleep(0.5)

    # Test card incompletion on activity feed
    workflow_page.click_recent_activity_link()
    workflow_page.validate_recent_activity_entry('Cover Letter card was '
                                                 'marked as incomplete',
                                                 staff_user['name'])
    workflow_page.click_close_overlay()

  # def test_cover_letter_file_submission(self):
  #   """
  #   test_cover_letter_file_submission: Tests the cover letter file upload and the admin card file
  #     download
  #   :return: void function
  #   """
  #   logging.info('Test Cover Letter Task::letter_file_upload')
  #   user_type = random.choice(users)
  #   dashboard = self.cas_login(user_type['email'])
  #   dashboard.click_create_new_submission_button()
  #   self.create_article(journal='PLOS Wombat', type_='Research', format='word')
  #   manuscript_page = ManuscriptViewerPage(self.getDriver())
  #   manuscript_page.page_ready_post_create()
  #   short_doi = manuscript_page.get_short_doi()
  #   manuscript_page.click_task('Cover Letter')
  #   cover_letter_task = CoverLetterTask(self.getDriver())
  #   cover_letter_task.task_ready()
  #   cover_letter_task.upload_letter()
  #   cover_letter_task.click_completion_button()
  #   cover_letter_task.logout()
  #
  #   # Test card
  #   staff_user = random.choice(editorial_users)
  #   dashboard_page = self.cas_login(email=staff_user['email'])
  #   dashboard_page.page_ready()
  #   dashboard_page.go_to_manuscript(short_doi)
  #   self._driver.navigated = True
  #   paper_viewer = ManuscriptViewerPage(self.getDriver())
  #   paper_viewer.page_ready()
  #   # go to wf
  #   paper_viewer.click_workflow_link()
  #   workflow_page = WorkflowPage(self.getDriver())
  #   workflow_page.page_ready()
  #   workflow_page.click_card('cover_letter')
  #   cover_letter_card = CoverLetterCard(self.getDriver())
  #   cover_letter_card.card_ready()
  #   cover_letter_card.validate_uploaded_file_download(
  #       cover_letter_task.get_last_uploaded_letter_file())
  #
  # def test_cover_letter_file_replace(self):
  #   """
  #   test_cover_letter_file_replace: Tests the replacing of an uploaded cover letter file
  #   :return: void function
  #   """
  #   logging.info('Test Cover Letter Task::letter_file_replace')
  #   user_type = random.choice(users)
  #   dashboard = self.cas_login(user_type['email'])
  #   dashboard.click_create_new_submission_button()
  #   self.create_article(journal='PLOS Wombat', type_='Research')
  #   manuscript_page = ManuscriptViewerPage(self.getDriver())
  #   manuscript_page.page_ready_post_create()
  #   manuscript_page.click_task('Cover Letter')
  #   cover_letter_task = CoverLetterTask(self.getDriver())
  #   cover_letter_task.task_ready()
  #   cover_letter_task.upload_letter()
  #   cover_letter_task.replace_letter()
  #
  # def test_cover_letter_file_delete(self):
  #   """
  #   test_cover_letter_file_delete: Tests the deleting of an uploaded cover letter file
  #   :return: void function
  #   """
  #   logging.info('Test Cover Letter Task::letter_file_delete')
  #   user_type = random.choice(users)
  #   dashboard = self.cas_login(user_type['email'])
  #   dashboard.click_create_new_submission_button()
  #   self.create_article(journal='PLOS Wombat', type_='Research')
  #   manuscript_page = ManuscriptViewerPage(self.getDriver())
  #   manuscript_page.page_ready_post_create()
  #   manuscript_page.click_task('Cover Letter')
  #   cover_letter_task = CoverLetterTask(self.getDriver())
  #   cover_letter_task.task_ready()
  #   cover_letter_task.upload_letter()
  #   cover_letter_task.remove_letter()
  #
  # def test_cover_letter_file_download(self):
  #   """
  #   test_cover_letter_file_delete: Tests the downloading of an uploaded cover letter file
  #   :return: void function
  #   """
  #   logging.info('Test Cover Letter Task::letter_file_download')
  #   user_type = random.choice(users)
  #   dashboard = self.cas_login(user_type['email'])
  #   dashboard.click_create_new_submission_button()
  #   self.create_article(journal='PLOS Wombat', type_='Research')
  #   manuscript_page = ManuscriptViewerPage(self.getDriver())
  #   manuscript_page.page_ready_post_create()
  #   manuscript_page.click_task('Cover Letter')
  #   cover_letter_task = CoverLetterTask(self.getDriver())
  #   cover_letter_task.task_ready()
  #   cover_letter_task.upload_letter()
  #   cover_letter_task.download_letter()
  #
  # def test_cover_letter_text_submission(self):
  #   """
  #   test_cover_letter_text_submission: Tests the cover letter text submission and admin card view
  #   :return: void function
  #   """
  #   logging.info('Test Cover Letter Task::letter_textarea')
  #   user_type = random.choice(users)
  #   dashboard = self.cas_login(user_type['email'])
  #   dashboard.click_create_new_submission_button()
  #   self.create_article(journal='PLOS Wombat', type_='Research')
  #   manuscript_page = ManuscriptViewerPage(self.getDriver())
  #   manuscript_page.page_ready_post_create()
  #   short_doi = manuscript_page.get_short_doi()
  #   manuscript_page.click_task('Cover Letter')
  #   cover_letter_task = CoverLetterTask(self.getDriver())
  #   cover_letter_task.task_ready()
  #   cover_letter_task.validate_letter_textarea()
  #   cover_letter_task.logout()
  #
  #   # Test card
  #   staff_user = random.choice(editorial_users)
  #   dashboard_page = self.cas_login(email=staff_user['email'])
  #   dashboard_page.page_ready()
  #   dashboard_page.go_to_manuscript(short_doi)
  #   self._driver.navigated = True
  #   paper_viewer = ManuscriptViewerPage(self.getDriver())
  #   paper_viewer.page_ready()
  #   # go to wf
  #   paper_viewer.click_workflow_link()
  #   workflow_page = WorkflowPage(self.getDriver())
  #   workflow_page.page_ready()
  #   workflow_page.click_card('cover_letter')
  #   cover_letter_card = CoverLetterCard(self.getDriver())
  #   cover_letter_card.card_ready()
  #   cover_letter_card.validate_textarea_submitted_text(cover_letter_task.get_textarea_sample_text())
  #   cover_letter_card.validate_textarea_text_editing()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
