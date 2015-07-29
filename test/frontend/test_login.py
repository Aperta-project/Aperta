#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta login page

"""
__author__ = 'jgray@plos.org'

from ..Base.Decorators import MultiBrowserFixture
from ..Base.FrontEndTest import FrontEndTest
from Pages.login_page import LoginPage
import time


@MultiBrowserFixture
class ApertaLoginTest(FrontEndTest):
  def test_validate_components_styles(self):
    """
    Validates the presence of the following provided elements:
      Welcome Text, Login Field, Password Field, Forgot pw link, Remember me checkbox, Sign In button, Sign Up link
    """
    login_page = LoginPage(self.getDriver())
    login_page.validate_initial_page_elements_styles()
    # Valid email, invalid pw
    login_page.enter_login_field('jgray@plos.org')
    login_page.enter_password_field('in|fury7')
    login_page.click_sign_in_button()
    login_page.validate_invalid_login_attempt()

    # Invalid email, invalid pw
    login_page.enter_login_field('jgrey@plos.org')
    login_page.enter_password_field('in|fury8')
    login_page.click_sign_in_button()
    login_page.validate_invalid_login_attempt()

    # valid email login
    login_page.enter_login_field('jgray@plos.org')
    login_page.enter_password_field('in|fury8')
    login_page.click_sign_in_button()
    login_page.sign_out()
    login_page.validate_signed_out_msg()

    # valid uname login
    login_page.enter_login_field('jgray')
    login_page.enter_password_field('in|fury8')
    login_page.click_sign_in_button()

if __name__ == '__main__':
  FrontEndTest._run_tests_randomly()

