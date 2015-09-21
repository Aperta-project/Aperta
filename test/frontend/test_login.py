#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta login page and associated forgot password page

"""
__author__ = 'jgray@plos.org'

from Base.Decorators import MultiBrowserFixture
#from Base.FrontEndTest import FrontEndTest
from frontend.common_test import CommonTest
from Pages.login_page import LoginPage
from Base.Resources import login_valid_email, login_invalid_email, login_valid_uid, login_valid_pw, login_invalid_pw
from Pages.dashboard import DashboardPage

@MultiBrowserFixture
class ApertaLoginTest(CommonTest):
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
    login_page = LoginPage(self.getDriver())
    login_page.validate_initial_page_elements_styles()

    # Valid email, invalid pw
    login_page.enter_login_field(login_valid_email)
    login_page.enter_password_field(login_invalid_pw)
    login_page.click_sign_in_button()
    login_page.validate_invalid_login_attempt()

    # Invalid email, invalid pw
    login_page.enter_login_field(login_invalid_email)
    login_page.enter_password_field(login_invalid_pw)
    login_page.click_sign_in_button()
    login_page.validate_invalid_login_attempt()

    # Forgot password link - modal validation
    login_page.open_fyp()
    login_page.validate_fyp_elements_styles_function()
    login_page.close_fyp()

    # valid email login
    login_page.enter_login_field(login_valid_email)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    login_page.sign_out()
    login_page.validate_signed_out_msg()

    # valid uname login
    login_page.enter_login_field(login_valid_uid)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    login_page.sign_out()
    login_page.validate_signed_out_msg()

    # forgotten password send email
    login_page.open_fyp()
    login_page.enter_fyp_field(login_valid_uid)
    login_page.click_sri_button()
    login_page.validate_fyp_email_fmt_error()
    login_page.enter_fyp_field(login_valid_email)
    login_page.click_sri_button()
    login_page.validate_reset_pw_msg()

    # Remember me function
    login_page.validate_remember_me(login_valid_email, login_valid_pw)

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
