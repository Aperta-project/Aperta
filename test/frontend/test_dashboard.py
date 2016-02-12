#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta dashboard page and its associated View Invitations and Create New Submission
overlays.

Note that this case does NOT test actually creating a new manuscript, or accepting or declining an invitation
Those acts are expected to be defined in

"""
__author__ = 'jgray@plos.org'

import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_pw, rv_login, fm_login, ae_login, he_login, oa_login
from frontend.common_test import CommonTest
from Pages.dashboard import DashboardPage
from Pages.login_page import LoginPage

# au and sa are commented out because they run into APERTA-5415 which is a code bug
users = [ # au_login,
         rv_login,
         fm_login,
         ae_login,
         he_login,
         # sa_login,
         oa_login
         ]


@MultiBrowserFixture
class ApertaDashboardTest(CommonTest):
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
    print('Logging in as user: {}'.format(user_type))
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(user_type['user'])
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()

    dashboard_page = DashboardPage(self.getDriver())
    dashboard_page.validate_initial_page_elements_styles()
    dashboard_page.validate_invite_dynamic_content(user_type['user'])
    active_manuscript_count = dashboard_page.validate_manuscript_section_main_title(user_type['user'])
    if active_manuscript_count > 0:
      dashboard_page.validate_active_manuscript_section(user_type['user'], active_manuscript_count)
    inactive_manuscript_count = dashboard_page.validate_inactive_manuscript_section(user_type['user'])
    if active_manuscript_count == 0 and inactive_manuscript_count == 0:
      dashboard_page.validate_no_manus_info_msg()

    # The dashboard navigation elements will change based on a users permissions
    # Author gets Close, Title, Profile Link with Image, Dashboard Link, Signout Link, separator, Feedback Link
    #
    dashboard_page.validate_nav_toolbar_elements(user_type['user'])

    # Validate View Invites modal (optional)
    invites = dashboard_page.is_invite_stanza_present(user_type['user'])
    if invites > 0:
      dashboard_page.click_view_invites_button()
      dashboard_page.validate_view_invites(user_type['user'])
    # Validate Create New Submissions modal
    dashboard_page.click_create_new_submission_button()
    # We recently became slow drawing this overlay (20151006)
    time.sleep(5)
    dashboard_page.validate_create_new_submission()


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
