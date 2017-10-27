#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This is an explicit test of the Create New Submission process with any variants, currently the "normal" and the
  "Preprint overlay" processes
"""

import logging
import os
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users

from frontend.common_test import CommonTest
from .Pages.dashboard import DashboardPage
from .Pages.manuscript_viewer import ManuscriptViewerPage
from frontend.Overlays.submission_review import SubmissionReviewOverlay

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class ApertaCNSTest(CommonTest):
  """
  Two tests explicit to the current two paths of creating a new submission. Relies on the seeding data provided by
    test_add_stock_mmt.
  """
  def test_smoke_validate_create_to_submit_no_preprint_overlay(self, init=True):
    """
    test_cns: Validates Creating a new document - needs extension to take it through to Submit
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission
    """
    logging.info('CNSTest::test_smoke_validate_create_to_submit_no_preprint_overlay')
    current_path = os.getcwd()
    logging.info(current_path)
    user_type = random.choice(users)
    dashboard_page = self.cas_login(email=user_type['email']) if init \
        else DashboardPage(self.getDriver())
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='cns_test', journal='PLOS Wombat', type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    manuscript_page.validate_ihat_conversions_success(fail_on_missing=True)
    # Outputting the title allows us to validate update following conversion
    manuscript_page.get_paper_short_doi_from_url()
    title = manuscript_page.get_paper_title_from_page()
    logging.info(u'Paper page title is: {0}'.format(title))

  def test_core_validate_create_to_submit_with_preprint_overlay(self, init=True):
    """
    test_cns: Validates Creating a new document - needs extension to take it through to Submit with the preprint
    overlay in the create sequence.
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission and Preprint Posting
    """
    logging.info('CNSTest::validate_core_create_to_submit_with_preprint_overlay')
    current_path = os.getcwd()
    logging.info(current_path)
    user_type = random.choice(users)
    dashboard_page = self.cas_login(email=user_type['email']) if init \
        else DashboardPage(self.getDriver())
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='cns_w_preprint_overlay', journal='PLOS Wombat',
                        type_='Preprint Eligible', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    manuscript_page.validate_ihat_conversions_success(fail_on_missing=True)
    # Outputting the title allows us to validate update following conversion
    manuscript_page.get_paper_short_doi_from_url()
    title = manuscript_page.get_paper_title_from_page()
    logging.info(u'Paper page title is: {0}'.format(title))

  def test_core_validate_review_submission_overlay(self):
    """
    test_cns: Validate review submission overlay
    """
    logging.info('CNSTest::validate_core_review_submission_overlay')
    author = random.choice(users)
    logging.info('Running test_validate_component_styles')
    logging.info('Logging in as {0}'.format(author))
    dashboard_page = self.cas_login(email=author['email'])
    dashboard_page._wait_on_lambda(lambda: len(dashboard_page._gets(dashboard_page._dashboard_invite_title)) >= 1)
    # dashboard_page.page_ready()
    # create a new manuscript
    dashboard_page.click_create_new_submission_button()
    #self.create_article(journal='PLOS Yeti', type_='No Author Tasks', random_bit=True, format_='word')
    self.create_article(title='cns_review_submission_overlay', journal='PLOS Wombat',
                        type_='Preprint Eligible', random_bit=True)
    ms_page = ManuscriptViewerPage(self.getDriver())
    ms_page.page_ready_post_create()
    # get doi
    short_doi = ms_page.get_paper_short_doi_from_url()
    logging.info("Assigned paper short doi: {0}".format(short_doi))
    # open to check style
    review_before_submission = ms_page.is_review_before_submission()
    if review_before_submission:
      ms_page.complete_task("Preprint Posting")
    ms_page.complete_task('Title And Abstract')
    ms_page.complete_task('Upload Manuscript')
    ms_page._wait_for_element(ms_page._get(ms_page._submit_button), 1)
    submit_button = ms_page._get(ms_page._submit_button)

    if review_before_submission:
      logging.info("Validating Review Submission overlay")
      assert submit_button.text.lower() == 'review before submission'
      ms_page._get(ms_page._submit_button).click()
      submission_review_overlay = SubmissionReviewOverlay(self.getDriver())
      submission_review_overlay.overlay_ready()
      submission_review_overlay.validate_styles_and_components()
      ms_pdf_link = submission_review_overlay._get(submission_review_overlay._review_ms_file_link)
      ms_page.validate_manuscript_downloaded_file(ms_pdf_link, format='pdf')
      submission_review_overlay.select_submit_or_make_changes()
    else:
      logging.info("No Review Submission overlay for the manuscript")
      assert submit_button.text.lower() == 'submit'

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
