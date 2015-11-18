#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta Admin page.
"""
__author__ = 'jgray@plos.org'

import random

from Base.Decorators import MultiBrowserFixture
#from Base.FrontEndTest import FrontEndTest
from Base.Resources import login_valid_pw, sa_login, oa_login, au_login, rv_login, ae_login, he_login, fm_login
from Pages.admin import AdminPage
from Pages.dashboard import DashboardPage
from Pages.login_page import LoginPage
from frontend.common_test import CommonTest


users = [oa_login,
         sa_login,
         ]

all_users = [sa_login,
             oa_login,
             au_login,
             rv_login,
             ae_login,
             he_login,
             fm_login,
             ]

user_search = ['OA', 'FM', 'MM', 'RV']

@MultiBrowserFixture
class ApertaAdminTest(CommonTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
       - Base Admin page
         - User Search
         - Navigation Menu (changed colors)
         - Title element and Journal links
       - Journal specific admin page
         # TODO: - Menu Bar
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
    print('Logging in as user: ' + user_type)
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(user_type)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()

    dashboard_page = DashboardPage(self.getDriver())
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    adm_page.validate_page_elements_styles_functions(user_type)
    adm_page.validate_search_edit_user(random.choice(user_search))
    adm_page.validate_add_new_journal(user_type)
    adm_page.validate_nav_toolbar_elements(user_type)

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
