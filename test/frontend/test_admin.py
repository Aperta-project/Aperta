#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta Admin page.
"""
__author__ = 'jgray@plos.org'

import random

from Base.Decorators import MultiBrowserFixture
from Base.FrontEndTest import FrontEndTest
from Base.Resources import login_valid_pw, sa_login, oa_login
from Pages.admin import AdminPage
from Pages.dashboard import DashboardPage
from Pages.login_page import LoginPage

users = [oa_login,
         sa_login,
         ]


@MultiBrowserFixture
class ApertaAdminTest(FrontEndTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
       - Base Admin page
         - User Search
         - Navigation Menu (changed colors)
         - Title element and Journal links
       - Journal specific admin page
         - Menu Bar
         - User Search
         - User List and role assignment
         - Role Title, Add Role, Role table, Edit and Delete Roles
         - Available Task Types
         - Edit Task Types
         - Manuscript Manager Templates
         - Add Template, Edit Template and Delete Template
         - Style Settings
           - Upload Epub Cover
           - Edit Epub CSS
           - Edit PDF CSS
           - Edit Manuscript CSS
  """
  def test_validate_components_styles(self):
    """
    Validates the presence of the following elements:


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
    pt_page.validate_page_elements_styles_functions(user_type)
    pt_page.click_left_nav()
    pt_page.validate_nav_elements(user_type)

if __name__ == '__main__':
  FrontEndTest._run_tests_randomly()
