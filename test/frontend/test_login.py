#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta login page and associated forgot password page

"""
import logging
import os
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_email, login_invalid_email, login_valid_uid, \
  login_valid_pw, login_invalid_pw, users, editorial_users, external_editorial_users, admin_users
from frontend.common_test import CommonTest
from Pages.login_page import LoginPage
from Pages.akita_login_page import AkitaLoginPage
from Pages.akita_signup_page import AkitaSignupPage
from Pages.dashboard import DashboardPage
from Pages.orcid_login_page import OrcidLoginPage

__author__ = 'jgray@plos.org'

users = users + editorial_users + external_editorial_users + admin_users


@MultiBrowserFixture
class ApertaLoginPageLayoutTest(CommonTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
         - login page
         - forgot password page
  """
  def test_validate_components_styles(self):
    """
    test_login: validates elements and styles for the login page, regardless enabled login methods
    Validates the presence of the following provided elements:
      Welcome Text, Login Field, Password Field, Forgot pw link, Remember me checkbox, Sign In
      button, Sign Up link, Sign in with PLOS (CAS) button, Create PLOS Account (CAS) button, Sign
      in with ORCID button
    :return: void function
    """
    logging.info('Test Login::components_styles')
    current_path = os.getcwd()
    logging.info(current_path)
    login_page = LoginPage(self.getDriver())
    native_login_enabled = login_page.validate_initial_page_elements_styles()
    logging.info('Native Login is enabled: {0}'.format(native_login_enabled))
    if native_login_enabled:
      # Forgot password link - modal validation
      login_page.open_fyp()
      login_page.validate_fyp_elements_styles_function()
      login_page.close_fyp()


@MultiBrowserFixture
class ApertaNativeLoginTest(CommonTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
         - login page
         - forgot password page
     - validate sign in and sign out and accompanying error messages
     - validate remember me function (only by cookie validation)
     - validate forgot password function (excludes email receipt validation)
  """
  def test_validate_native_login(self):
    """
    test_login: Validate Native Login function, if enabled.
    Validates the presence of the following provided elements:
      Welcome Text, Login Field, Password Field, Forgot pw link, Remember me checkbox, Sign In
      button, Sign Up link
    :return: void function
    """
    logging.info('Test Login::Native Login')
    current_path = os.getcwd()
    logging.info(current_path)
    login_page = LoginPage(self.getDriver())
    native_login_enabled = login_page.validate_initial_page_elements_styles()
    logging.info('Native Login is enabled: {0}'.format(native_login_enabled))
    if native_login_enabled:
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


@MultiBrowserFixture
class ApertaCASLoginTest(CommonTest):
  """
  Self imposed AC:
     - validate sign in and sign out using NED CAS and accompanying error messages
  """
  def test_validate_cas_login(self):
    """
    test_login: Validates signin via NED CAS account, if enabled
    :return: void function
    """
    logging.info('Test Login::CAS Login')
    current_path = os.getcwd()
    logging.info(current_path)
    test_user = random.choice(users)
    login_page = LoginPage(self.getDriver())
    # Valid email, valid pw
    login_page.login_cas()
    akita_signin = AkitaLoginPage(self.getDriver())
    akita_signin.validate_cas_login_elements()
    akita_signin.enter_login_field(test_user['email'])
    akita_signin.enter_password_field(login_valid_pw)
    akita_signin.click_sign_in_button()
    dashboard_page = DashboardPage(self.getDriver())
    dashboard_page.validate_initial_page_elements_styles()

  def test_validate_cas_signup(self):
    """
    test_login: Validates NED CAS signup wiring, elements and styles
      Does not actually register a new account
    :return: void function
    """
    logging.info('Test Login::CAS sign-up')
    current_path = os.getcwd()
    logging.info(current_path)
    login_page = LoginPage(self.getDriver())
    environment_url = login_page.get_current_url()
    logging.info(environment_url)
    # Valid email, valid pw
    login_page.signup_cas()
    akita_signup = AkitaSignupPage(self.getDriver())
    akita_signup.validate_cas_signup_elements()
    akita_signup.confirm_correct_url_form(environment_url)


@MultiBrowserFixture
class ApertaORCIDLoginTest(CommonTest):
  """
  Self imposed AC:
     - validate sign in and sign out using ORCID and accompanying error messages
  """
  def test_validate_orcid_login(self):
    """
    test_login: Validates ORCID sign-in wiring, elements and styles
    Does not validate actual sign-in
    Validates the Signin via pre-existing ORCID account link
    Note, this is currently not correctly wired in, so just doing a minimal test
    that we are pointing at the correct page.
    :return: void function
    """
    logging.info('Test Login::ORCID Login')
    current_path = os.getcwd()
    logging.info(current_path)
    login_page = LoginPage(self.getDriver())
    orcid_login_enabled = login_page.validate_initial_page_elements_styles()
    logging.info('ORCID Login is enabled: {0}'.format(orcid_login_enabled))
    if orcid_login_enabled:
      # Valid email, valid pw
      login_page.login_orcid()
      orcid_login = OrcidLoginPage(self.getDriver())
      orcid_login.validate_orcid_login_elements()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
