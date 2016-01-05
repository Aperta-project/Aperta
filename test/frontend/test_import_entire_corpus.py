#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates the Aperta Create New Submission through Submit process.
"""
__author__ = 'jgray@plos.org'

import logging
import os
import random
import time

from selenium.common.exceptions import NoSuchElementException

from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_pw, au_login
from frontend.common_test import CommonTest
from Base.Resources import docs
from Base.CustomException import ElementDoesNotExistAssertionError
from Pages.manuscript_viewer import ManuscriptViewerPage

# au and sa are commented out because they run into APERTA-5415 which is a code bug
users = [au_login]

cards = ['cover_letter',
         'billing',
         'figures',
         'authors',
         'supporting_info',
         'upload_manuscript',
         'prq',
         'review_candidates',
         'revise_task',
         'competing_interests',
         'data_availability',
         'ethics_statement',
         'financial_disclosure',
         'new_taxon',
         'reporting_guidelines',
         'changes_for_author',
         ]


@MultiBrowserFixture
class ApertaImportEntireCorpusTest(CommonTest):
  """
  Self imposed AC:
    log in as author
    Aperta takes you to Dashboard
    click “create new submission”
    enter a title
    select the journal that you are submitting to
    choose the journal PLOS Wombat
    choose the type of paper (Research)
    Import the first document from the doc list in Resources.py
    Wait for a return status, record result, move to next document in list until all docs processed
    Report the names of the Failures
  """
  def test_import_documents(self):
    """

    """
    doclist = docs
    user_type = random.choice(users)
    print('Logging in as user: {}'.format(user_type))
    dashboard_page = self.login(email=user_type['user'], password=login_valid_pw)
    faileddocs = []
    noalertdocs = []
    for doc in doclist:
      dashboard_page.click_create_new_submission_button()
      # We recently became slow drawing this overlay (20151006)
      time.sleep(2)
      title = dashboard_page.title_generator()
      dashboard_page.enter_title_field(title)
      dashboard_page.select_journal_and_type('PLOS Wombat', 'Research')
      time.sleep(3)
      doc2upload = random.choice(doclist)
      doclist.remove(doc2upload)
      logging.info('Sending document: ' + os.path.join(os.getcwd() + '/frontend/assets/docs/' + doc2upload))
      fn = os.path.join(os.getcwd() + '/frontend/assets/docs/' + doc2upload)
      if os.path.isfile(fn):
        self._driver.find_element_by_id('upload-files').send_keys(fn)
      else:
        raise IOError('Document file not found: ' + fn)
      dashboard_page.click_upload_button()
      # Time needed for iHat conversion. This is not quite enough time in all circumstances
      time.sleep(7)
      manuscript_page = ManuscriptViewerPage(self.getDriver())
      try:
        manuscript_page.validate_ihat_conversions_success()
      except NoSuchElementException:
        try:
          manuscript_page.validate_ihat_conversions_failure()
          logging.notice(doc2upload + ' failed to convert successfully')
          faileddocs.append(doc2upload)
        except NoSuchElementException:
          logging.error('Neither success nor failure message found for document upload of: ' + doc2upload)
      manuscript_page.close_flash_message()
      manuscript_page.click_dashboard_link()
      time.sleep(1)
      logging.info('Failed imports: ')
      logging.info(faileddocs)
      logging.info('NoAlert imports: ')
      logging.info(noalertdocs)


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
