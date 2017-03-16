#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Resources import users, editorial_users
#from Base.PostgreSQL import PgSQL
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage
from Tasks.upload_manuscript_task import UploadManuscriptTask
from frontend.common_test import CommonTest

"""
This test case validates the upload manuscript
"""
__author__ = 'sbassi@plos.org'


@MultiBrowserFixture
class UploadManuscriptTest(CommonTest):
  """
  This class test XXX

  """

  def _test_validate_styles_doc(self):
    """
    test_upload_ms: Validate elements and styles for the upload manuscript task
    """
    logging.info('Test Upload ms::components_styles')
    user = random.choice(users)
    logging.info('Running test_validate_component_styles')
    logging.info('Logging in as {0}'.format(user))
    dashboard_page = self.cas_login(email=user['email'])
    dashboard_page.page_ready()
    # create a new manuscript
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='NoCards', random_bit=True)
    ms_page = ManuscriptViewerPage(self.getDriver())
    ms_page.page_ready_post_create()
    ms_page.complete_task('Upload Manuscript', style_check=True)

  def _test_validate_styles_pdf(self):
    """
    test_upload_ms: Validate elements and styles for the upload manuscript task
    """
    logging.info('Test Upload ms::components_styles')
    user = random.choice(users)
    logging.info('Running test_validate_component_styles')
    logging.info('Logging in as {0}'.format(user))
    dashboard_page = self.cas_login(email=user['email'])
    dashboard_page.page_ready()
    # create a new manuscript
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='NoCards', random_bit=True,
        format='pdf')
    ms_page = ManuscriptViewerPage(self.getDriver())
    ms_page.page_ready_post_create()
    ms_page.complete_task('Upload Manuscript', style_check=True)

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
    self.create_article(journal='PLOS Wombat', type_='NoCards', random_bit=True,
        format='pdf')
    ms_page = ManuscriptViewerPage(self.getDriver())
    ms_page.page_ready_post_create()
    # get doi
    short_doi = ms_page.get_paper_short_doi_from_url()
    logging.info("Assigned paper short doi: {0}".format(short_doi))
    # Test that the task exist, is not completed and closed:
    assert ms_page.is_task_present('Upload Manuscript')
    assert not ms_page.is_task_marked_complete('Upload Manuscript')
    assert not ms_page.is_task_open('Upload Manuscript')
    ms_page.complete_task('Upload Manuscript')
    time.sleep(3)
    ms_page.click_submit_btn()
    time.sleep(3)
    ms_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    ms_page.close_submit_overlay()
    ms_page.logout()

    editor = random.choice(editorial_users)
    dashboard_page = self.cas_login(email=editor['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
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
    #paper_viewer.
    ms_page.click_task('Upload Manuscript')
    upms = UploadManuscriptTask(self.getDriver())
    upms._wait_for_element(upms._get(upms._completion_button))
    upms.click_completion_button()
    # look for errors here
    warning = upms._get(upms._upload_source_warning)
    assert warning.get_attribute('title') == 'Please upload your source file', \
        '{0} not Please upload your source file'.format(warning.get_attribute('title'))


    import pdb; pdb.set_trace()
    # DO THIS FROM TASK
    ms_page.complete_task('Upload Manuscript', data={'source': ''})
    assert ms_page.is_task_completed('Upload Manuscript') == True

    #import pdb; pdb.set_trace()
    # CLICK IF NOT OPEN
    #UploadManuscriptTask

    #ms_page.complete_task('Upload Manuscript', style_check=False)




    #ms_page.complete_task('Upload Manuscript', data={'source': ''})




if __name__ == '__main__':
  CommonTest._run_tests_randomly()
