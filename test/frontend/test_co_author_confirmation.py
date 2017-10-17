#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Authors Task.
"""

import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users
from frontend.Tasks.authors_task import AuthorsTask
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.correspondence_history import CorrespondenceHistory
from frontend.common_test import CommonTest
from Base.Resources import author, group_author, super_admin_login

__author__ = 'achoe@plos.org'


@MultiBrowserFixture
class CoAuthorConfirmationTest(CommonTest):

  def test_individual_coauthor_confirmation_email(self):
    """
    Validates the function of the co-author confirmation email feature.
    Note: Since we do not currently have a means of validating an email sent
    via Aperta, this test will rely on the correspondence history page. This
    means that this test will be limited in that we will not be able to update
    co-author status via email through this test. Validation will instead focus
    on the different element of the co-author confirmation email (text, links, etc.).
    Once we have testable emails configured, we will need to update this test accordingly.
    :return: None
    """
    logging.info('Test Co-author Confirmation::individual_co_author_confirmation_email')
    current_path = os.getcwd()
    logging.info(current_path)
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    mmt = 'Essay'
    # Per APERTA-10873, co-author confirmation is disabled for non-PLOS Biology journals.
    self.create_article(journal='PLOS Biology', type_=mmt, random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_canonical_url = manuscript_page.get_current_url().split('?')[0]
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.complete_task('Title And Abstract')
    manuscript_page.complete_task('Ethics Statement')
    manuscript_page.complete_task('Cover Letter')
    manuscript_page.complete_task('Figures')
    manuscript_page.complete_task('Reviewer Candidates')
    manuscript_page.complete_task('Supporting Info')
    manuscript_page.complete_task('Competing Interests')
    manuscript_page.complete_task('Financial Disclosure')
    manuscript_page.complete_task('Additional Information')
    manuscript_page.complete_task('Early Article Posting')
    # Now, on the Authors card, we add a co-author
    manuscript_page.click_task('Authors')
    authors_task = AuthorsTask(self.getDriver())
    authors_task.add_individual_author_task_action()
    authors_task.edit_author(creator_user)
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_modal()

    # logout and enter as a site admin - we don't have editorial users seeded for PLOS Biology
    manuscript_page.logout()
    site_adm_user = super_admin_login
    logging.info('Logging in as {0}'.format(site_adm_user))
    dashboard_page = self.cas_login(email=site_adm_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()

    # go to Correspondence History
    paper_viewer.click_correspondence_link()
    correspondence_page = CorrespondenceHistory(self.getDriver())
    correspondence_page.page_ready()
    correspondence_page.validate_co_author_confirmation_email()

  def test_group_coauthor_confirmation_email(self):
    """
    Validates the function of the co-author confirmation email feature.
    Note: Since we do not currently have a means of validating an email sent
    via Aperta, this test will rely on the correspondence history page. This
    means that this test will be limited in that we will not be able to update
    co-author status via email through this test. Validation will instead focus
    on the different element of the co-author confirmation email (text, links, etc.).
    Once we have testable emails configured, we will need to update this test accordingly.
    :return: None
    """
    logging.info('Test Co-author Confirmation::individual_co_author_confirmation_email')
    current_path = os.getcwd()
    logging.info(current_path)
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    mmt = 'Essay'
    # Per APERTA-10873, co-author confirmation is disabled for non-PLOS Biology journals.
    self.create_article(journal='PLOS Biology', type_=mmt, random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_canonical_url = manuscript_page.get_current_url().split('?')[0]
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.complete_task('Title And Abstract')
    manuscript_page.complete_task('Ethics Statement')
    manuscript_page.complete_task('Cover Letter')
    manuscript_page.complete_task('Figures')
    manuscript_page.complete_task('Reviewer Candidates')
    manuscript_page.complete_task('Supporting Info')
    manuscript_page.complete_task('Competing Interests')
    manuscript_page.complete_task('Financial Disclosure')
    manuscript_page.complete_task('Additional Information')
    manuscript_page.complete_task('Early Article Posting')
    # Now, on the Authors card, we add a co-author
    manuscript_page.click_task('Authors')
    authors_task = AuthorsTask(self.getDriver())
    authors_task.add_group_author_task_action()
    authors_task.edit_author(creator_user)
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_modal()

    # logout and enter as a site admin - we don't have editorial users seeded for PLOS Biology
    manuscript_page.logout()
    site_adm_user = super_admin_login
    logging.info('Logging in as {0}'.format(site_adm_user))
    dashboard_page = self.cas_login(email=site_adm_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()

    # go to Correspondence History
    paper_viewer.click_correspondence_link()
    correspondence_page = CorrespondenceHistory(self.getDriver())
    correspondence_page.page_ready()
    correspondence_page.validate_co_author_confirmation_email()


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
