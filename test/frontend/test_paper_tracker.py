#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta dashboard page and its associated View Invitations and Create New Submission
overlays.

Note that this case does NOT test actually creating a new manuscript, or accepting or declining an invitation
Those acts are expected to be defined in

"""
__author__ = 'jgray@plos.org'

from Base.Decorators import MultiBrowserFixture
from Base.FrontEndTest import FrontEndTest
from Pages.login_page import LoginPage
from Pages.dashboard import DashboardPage
from Pages.paper_tracker import PaperTrackerPage
from Base.Resources import login_valid_pw, fm_login, he_login, sa_login, oa_login
import random

users = [fm_login,
         he_login,
         oa_login,
         sa_login,
         ]


@MultiBrowserFixture
class ApertaPaperTrackerTest(FrontEndTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
         - dashboard page:
            - Optional Invitation elements
              - title, buttons
            - Submissions section
              - title, button, manuscript details
         - view invitations modal dialog elements and function
         - create new submission modal dialog and function
  """
  def test_validate_components_styles(self):
    """
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission
    """
    user_type = random.choice(users)
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(user_type)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()

    dashboard_page = DashboardPage(self.getDriver())
    dashboard_page.click_left_nav()
    dashboard_page.click_paper_tracker_link()

    pt_page = PaperTrackerPage(self.getDriver())
    pt_page.validate_initial_page_elements_styles(user_type)
    pt_page.click_left_nav()
    pt_page.validate_nav_elements(user_type)

if __name__ == '__main__':
  FrontEndTest._run_tests_randomly()
