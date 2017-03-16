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

  def test_validate_styles_doc(self):
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

  def test_validate_styles_pdf(self):
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

    #ms_page.complete_task('Upload Manuscript', data={'source': ''})




if __name__ == '__main__':
  CommonTest._run_tests_randomly()
