#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates the Aperta Create New Submission through Submit process.
"""
__author__ = 'jgray@plos.org'

import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_pw, au_login, rv_login, fm_login, ae_login, he_login, sa_login, oa_login
from frontend.common_test import CommonTest
from Pages.dashboard import DashboardPage
from Pages.login_page import LoginPage

# au and sa are commented out because they run into APERTA-5415 which is a code bug
users = [au_login]


@MultiBrowserFixture
class ApertaBDDCNStoSubmitTest(CommonTest):
  """
  Self imposed AC:
    log in as author
    Aperta takes you to Dashboard
    click “create new submission”
    enter a title
    select the journal that you are submitting to
    choose the journal PLOS Wombat
    choose the type of paper (Research)
    drag manuscript/attach to “upload manuscript” or click “upload manuscript” to upload manuscript
    end up on the manuscript page
    begin working through the cards on the right-hand side (don’t have to go in order that they are displayed)
    general
    after you complete each card, check “complete” and “close” to return to manuscript page
    for a few cards, try to:
    check complete and close and then reopen to make sure that the comments saved
    don’t check complete, close and then reopen to see if the comments saved (everything should save)
    billing
    enter payee details
    select how you would like to pay
    cover letter
    paste in cover letter
    upload manuscript
    should be complete already (gray) but if not, upload the manuscript here
    figures
    check “yes, I confirm…”
    add new figures
    once figure is uploaded, enter figure captions\
    click “save”
    upload 1-2 figures
    one tiff and one eps
    ethics statement
    answer questions 1 and 2 and provide explanations when prompted
    reviewer candidates
    enter reviewer details for 2 reviewers (either recommend or oppose)
    enter a reviewer who doesn’t have an account in Aperta
    enter a reviewer who does have an account in Aperta
    confirm that the editor receives the reviewer recommendation card as it was completed by the submitting author
    reporting guidelines
    check Systematic Review or Meta-Analysis
    select and upload word doc
    supporting info
    “add new supporting information”
    add a title
    add a caption
    try uploading a docx, an excel file, pdf, ppt and any image file
    financial disclosures
    answer question “yes” and add 2 funders
    enter funder information
    indicate that one of them has a role in study design and input descriptoin
    be sure to confirm that the funder name appears appropriately in the published financial disclosure statement that is indicated at the bottom
    confirm that once a website is added to the funder information, a hyperlink is automatically created (associated to funder name below)
    authors
    add a corresponding author
    add one additional authors
    should be able to search an institution/affiliations
    publishing related questions
    select “yes” for at least one of the questions and provide the necessary information
    check to see if you are able to complete the card without providing certain information
    data availability
    doesn’t matter if you select “yes” or “no”
    competing interests
    answer yes, provide statement
    once you’ve completed all cards, check to make sure that all cards appear gray
    Hit SUBMIT and confirm

  """
  def test_validate_components_styles(self):
    """
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission
    """
    user_type = random.choice(users)
    print('Logging in as user: ' + user_type)
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(user_type)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()

    dashboard_page = DashboardPage(self.getDriver())
    # Validate Create New Submissions modal
    dashboard_page.click_create_new_submission_button()
    # We recently became slow drawing this overlay (20151006)
    time.sleep(2)
    title = dashboard_page.title_generator()
    dashboard_page.enter_title_field(title)
    dashboard_page.select_journal_and_type(' PLOS Wombat ', 'Research')
    time.sleep(3)


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
