#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta login page and associated forgot password page

"""
__author__ = 'jgray@plos.org'

from Base.Decorators import MultiBrowserFixture
from Base.FrontEndTest import FrontEndTest
from Pages.login_page import LoginPage
from Pages.dashboard import DashboardPage
from Base.Resources import login_valid_pw, au_login, rv_login, fm_login, ae_login, he_login, sa_login, oa_login
import random

users = [ au_login, rv_login, fm_login, ae_login, he_login, sa_login, oa_login ]

@MultiBrowserFixture
class ApertaDashboardTest(FrontEndTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
         - login page
         - forgot password page
     - validate sign in and sign out and accompanying error messages
     - validate remember me function (only by cookie validation)
     - validate forgot password function (excludes email receipt validation)
  """
  def test_validate_components_styles(self):
    """
    Validates the presence of the following provided elements:
      Welcome Text, Login Field, Password Field, Forgot pw link, Remember me checkbox, Sign In button, Sign Up link
    """
    user_type = random.choice(users)
    login_page = LoginPage(self.getDriver())
    login_page.validate_initial_page_elements_styles()
    login_page.enter_login_field(user_type)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()

    dashboard_page = DashboardPage(self.getDriver())
    dashboard_page.validate_initial_page_elements_styles()
    dashboard_page.validate_dynamic_content(user_type)

    # The dashboard navigation elements will change based on a users permissions
    # Author gets Close, Title, Profile Link with Image, Dashboard Link, Signout Link, separator, Feedback Link
    #
    dashboard_page.click_left_nav()
    dashboard_page.validate_nav_elements(user_type)

if __name__ == '__main__':
  FrontEndTest._run_tests_randomly()
