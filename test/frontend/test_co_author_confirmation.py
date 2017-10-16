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
from frontend.common_test import CommonTest
from Base.Resources import author, group_author, super_admin_login

__author__ = 'achoe@plos.org'


@MultiBrowserFixture
class CoAuthorConfirmationTest(CommonTest):
  def test_coauthor_confirmation_email(self):
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
    logging.info('Test Co-author Confirmation::co_author_confirmation_email')
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
    # time.sleep(4)
    # # add card invite AE with add new card
    # # Check if card is there
    # if not workflow_page.is_card('Initial Tech Check'):
    #   workflow_page.add_card('Initial Tech Check')
    # # click on invite academic editor
    # itc_card = ITCCard(self.getDriver())
    # workflow_page.click_initial_tech_check_card()
    # itc_card.validate_styles(paper_id)
    # data = itc_card.complete_card()
    # itc_card.click_autogenerate_btn()
    # time.sleep(2)
    # issues_text = itc_card.get_issues_text()
    # for index, checked in enumerate(data):
    #   if not checked and itc_card.email_text[index]:
    #     assert itc_card.email_text[index] in issues_text, \
    #         '{0} (Not checked item #{1}) not in {2}'.format(itc_card.email_text[index],
    #                                                         index, issues_text)
    #   elif checked and itc_card.email_text[index]:
    #     assert itc_card.email_text[index] not in issues_text, \
    #         '{0} (Checked item #{1}) not in {2}'.format(itc_card.email_text[index],
    #                                                     index, issues_text)
    # time.sleep(1)
    # itc_card.click_send_changes_btn()
    # all_success_messages = itc_card.get_flash_success_messages()
    # success_msgs = [msg.text.split('\n')[0] for msg in all_success_messages]
    # assert 'Author Changes Letter has been Saved' in success_msgs, success_msgs
    # assert 'The author has been notified via email that changes are needed. They will also '\
    #     'see your message the next time they log in to see their manuscript.' in success_msgs,\
    #     success_msgs
    # # Check not error message
    # try:
    #   itc_card._get(itc_card._flash_error_msg)
    #   # Note: Commenting out due to APERTA-7012
    #   # raise ElementExistsAssertionError('There is an unexpected error message')
    #   # logging.warning('There is an error message because of APERTA-7012')
    # except ElementDoesNotExistAssertionError:
    #   pass

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
