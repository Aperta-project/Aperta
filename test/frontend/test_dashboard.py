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
from Base.Resources import login_valid_pw, creator_login1, creator_login2, creator_login3, creator_login4, \
    creator_login5, reviewer_login, handling_editor_login, academic_editor_login, internal_editor_login, \
    staff_admin_login, pub_svcs_login, super_admin_login
from frontend.common_test import CommonTest
from Pages.dashboard import DashboardPage
from Pages.login_page import LoginPage

users = [creator_login1,
         creator_login2,
         creator_login3,
         creator_login4,
         creator_login5,
         reviewer_login,
         handling_editor_login,
         academic_editor_login,
         internal_editor_login,
         staff_admin_login,
         pub_svcs_login,
         super_admin_login,
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
  def test_validate_components_styles(self, init=True):
    """
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission
    """
    user_type = random.choice(users)
    print('Logging in as user: {}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email']) if init else DashboardPage(self.getDriver())
    dashboard_page.validate_initial_page_elements_styles()
    dashboard_page.validate_invite_dynamic_content(user_type['user'])
    active_manuscript_count = dashboard_page.validate_manuscript_section_main_title(user_type['user'])
    if active_manuscript_count > 0:
      dashboard_page.validate_active_manuscript_section(user_type['email'], active_manuscript_count)
    inactive_manuscript_count = dashboard_page.validate_inactive_manuscript_section(user_type['user'])
    if active_manuscript_count == 0 and inactive_manuscript_count == 0:
      dashboard_page.validate_no_manus_info_msg()
    # The dashboard navigation elements will change based on a users permissions
    # Author gets Close, Title, Profile Link with Image, Dashboard Link, Signout Link, separator, Feedback Link
    #
    dashboard_page.validate_nav_toolbar_elements(user_type['email'])

    # Validate View Invites modal (optional)
    invites = dashboard_page.is_invite_stanza_present(user_type['email'])
    if invites > 0:
      dashboard_page.click_view_invites_button()
      dashboard_page.validate_view_invites(user_type['email'])
    # Validate Create New Submissions modal
    dashboard_page.click_create_new_submission_button()
    # We recently became slow drawing this overlay (20151006)
    time.sleep(5)
    dashboard_page.validate_create_new_submission()


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
