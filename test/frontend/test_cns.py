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
    logging.info('CNSTest::validate_core_create_to_submit_wth_preprint_overlay')
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

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
