#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the common elements of the authenticated pages of Aperta

"""
__author__ = 'jgray@plos.org'

from Base.Decorators import MultiBrowserFixture
from Base.FrontEndTest import FrontEndTest
from Pages.login_page import LoginPage
from Pages.authenticated_page import AuthenticatedPage
from Base.Resources import login_valid_pw, au_login, rv_login, fm_login, ae_login, he_login, sa_login, oa_login
import random

users = [au_login, rv_login, fm_login, ae_login, he_login, sa_login, oa_login]

pages = ['/',
         '/flow_manager',
         '/paper_tracker',
         '/admin',
         ]


@MultiBrowserFixture
class ApertaAuthPageTest(FrontEndTest):
  """
  Self imposed AC:
    - validate page elements and styles for:
      Navigation menu
    - validate function for each selection in nav menu
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
    authenticated_page = AuthenticatedPage(self.getDriver())
    # The dashboard navigation elements will change based on a users permissions
    # Author gets Close, Title, Profile Link with Image, Dashboard Link, Signout Link, separator, Feedback Link
    #
    authenticated_page.click_left_nav()
    authenticated_page.validate_nav_elements(user_type)

if __name__ == '__main__':
  FrontEndTest._run_tests_randomly()
