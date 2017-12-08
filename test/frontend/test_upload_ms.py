#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This test case validates the upload manuscript
"""
import logging
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.workflow_page import WorkflowPage
from .Tasks.upload_manuscript_task import UploadManuscriptTask
from frontend.common_test import CommonTest

__author__ = 'sbassi@plos.org'


@MultiBrowserFixture
class UploadManuscriptTest(CommonTest):
  """
  This class test uploading a manuscript (ms) as a doc and as PDF.
  For PDF ms, checks for the source uploading.
  """

  def test_upload_doc_task(self):
    """
    test_upload_ms: Validate functions and styles for the upload manuscript task
    """
    logging.info('Test Upload ms::Upload doc[x]')
    author = random.choice(users)
    logging.info('Logging in as {0}'.format(author))
    dashboard_page = self.cas_login(email=author['email'])
    dashboard_page.page_ready()
    # create a new manuscript
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Testing Upload MS Task - doc test', journal='PLOS Wombat',
                        type_='NoCards', random_bit=True, format_='word')
    ms_page = ManuscriptViewerPage(self.getDriver())
    ms_page.page_ready_post_create()
    short_doi = ms_page.get_paper_short_doi_from_url()
    logging.info("Assigned paper short doi: {0}".format(short_doi))
    # Test that the task exist, is not completed and closed:
    assert ms_page.is_task_present('Upload Manuscript'), \
        'The task must be present and is not'
    assert not ms_page.is_task_marked_complete('Upload Manuscript'), \
        'The task is marked as complete and should not'
    assert not ms_page.is_task_open('Upload Manuscript'), \
        'The task is opened and must be closed'
    # open to check style
    ms_page.click_task('Upload Manuscript')
    ms_page._wait_on_lambda(lambda: bool(ms_page.is_task_open('Upload Manuscript')))
    # check style without source
    upms = UploadManuscriptTask(self.getDriver())
    upms.task_ready()
    # check uploaded file links visibility
    upms.validate_upload_file_links(upms._uploaded_file_box, task_editable=True, check_delete_link=False)

    upms.validate_styles()
    upms.click_completion_button()

    # Scroll to top to leave the complete button
    manuscript_id_text = ms_page._get(ms_page._paper_sidebar_manuscript_id)
    ms_page._scroll_into_view(manuscript_id_text)
    manuscript_id_text.click()

    assert ms_page.is_task_marked_complete('Upload Manuscript'), \
        'The task in not marked as complete and it should be completed'
    # check uploaded file links visibility
    upms.validate_upload_file_links(upms._uploaded_file_box, task_editable=False, check_delete_link=False)

  def test_upload_pdf_task(self):
    """
    test_upload_ms: Validate elements and styles for the upload manuscript task
    """
    logging.info('Test Upload ms::Upload PDF')
    author = random.choice(users)
    logging.info('Running test_validate_component_styles')
    logging.info('Logging in as {0}'.format(author))
    dashboard_page = self.cas_login(email=author['email'])
    dashboard_page.page_ready()
    # create a new manuscript
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Testing Upload MS Task - pdf test', journal='PLOS Wombat',
                        type_='NoCards', random_bit=True, format_='pdf')
    ms_page = ManuscriptViewerPage(self.getDriver())
    ms_page.page_ready_post_create()
    # get doi
    short_doi = ms_page.get_paper_short_doi_from_url()
    logging.info("Assigned paper short doi: {0}".format(short_doi))
    # Test that the task exist, is not completed and closed:
    assert ms_page.is_task_present('Upload Manuscript')
    assert not ms_page.is_task_marked_complete('Upload Manuscript')
    assert not ms_page.is_task_open('Upload Manuscript')
    # open to check style
    ms_page.complete_task('Title And Abstract')
    ms_page.click_task('Upload Manuscript')
    ms_page._wait_on_lambda(lambda: bool(ms_page.is_task_open('Upload Manuscript')))
    # check style without source
    upms = UploadManuscriptTask(self.getDriver())
    upms.task_ready()
    upms.validate_styles(type_='pdf')
    upms.click_completion_button()
    ms_page.click_submit_btn()
    ms_page.confirm_submit_btn()
    ms_page.close_submit_overlay()
    ms_page.logout()

    editor = random.choice(editorial_users)
    dashboard_page = self.cas_login(email=editor['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    paper_viewer.click_workflow_link()
    wf_page = WorkflowPage(self.getDriver())
    wf_page.page_ready()
    wf_page.click_card('register_decision')
    wf_page.complete_card('Register Decision')
    wf_page.logout()

    logging.info('Logging in as user: {0}'.format(author))
    dashboard_page = self.cas_login(email=author['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    ms_page = ManuscriptViewerPage(self.getDriver())
    ms_page.page_ready()
    ms_page.click_task('Upload Manuscript')
    upms = UploadManuscriptTask(self.getDriver())
    upms._wait_for_element(upms._get(upms._completion_button))
    upms.click_completion_button()
    # look for errors here
    warning = upms._get(upms._upload_source_warning)
    assert warning.get_attribute('title') == 'Please upload your source file', \
        '{0} instead of Please upload your source file'.format(warning.get_attribute('title'))
    upms.upload_source_file()
    upms.validate_styles(type_='pdf', source_uploaded=True)
    upms._wait_for_element(upms._get(upms._completion_button))
    upms.click_completion_button()
    # Scroll to top to leave the complete button
    manuscript_id_text = ms_page._get(ms_page._paper_sidebar_manuscript_id)
    ms_page._scroll_into_view(manuscript_id_text)
    manuscript_id_text.click()

    completed = ms_page.is_task_marked_complete('Upload Manuscript')
    assert completed, 'The task should be marked as completed and is not'
    # check uploaded file links visibility in completed state
    upms.validate_upload_file_links(upms._uploaded_file_box, task_editable=False, check_delete_link=False)
    upms.validate_upload_file_links(upms._upload_source_file_box, task_editable=False, check_delete_link=False)

if __name__ == '__main__':
  CommonTest.run_tests_randomly()
