#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Akita Login page.
"""

import urllib

from selenium.webdriver.common.by import By

from Base.PlosPage import PlosPage

__author__ = 'jgray@plos.org'


class AkitaSignupPage(PlosPage):
  """
  Model an abstract Akita login page
  """
  def __init__(self, driver):
    super(AkitaSignupPage, self).__init__(driver, '')

    # Locators - Instance members
    self._welcome_message = (By.TAG_NAME, 'h1')

    self._signin_link = (By.CSS_SELECTOR, 'p#already strong + a')
    self._forgot_pw_link = (By.CSS_SELECTOR, 'p#already strong + a + a')
    self._resend_confirm_email_link = (By.CSS_SELECTOR, 'p#already strong + a + a + a')

    self._email_textbox_label = (By.XPATH, '//label[@for="email_address"]')
    self._email_textbox = (By.ID, 'email_address')
    self._fname_textbox_label = (By.XPATH, '//label[@for="first_name"]')
    self._fname_textbox = (By.ID, 'first_name')
    self._lname_textbox_label = (By.XPATH, '//label[@for="last_name"]')
    self._lname_textbox = (By.ID, 'last_name')
    self._password_textbox_label = (By.XPATH, '//label[@for="password"]')
    self._password_textbox = (By.ID, 'password')
    self._confirm_password_textbox_label = (By.XPATH, '//label[@for="password_verify"]')
    self._confirm_password_textbox = (By.ID, 'password_verify')

    self._email_signup_cb = (By.CSS_SELECTOR, 'receive_emails')
    self._email_signup_label = (By.CSS_SELECTOR, '#registration_form img + div')

    self._create_acct_button = (By.CSS_SELECTOR, 'button.btn-primary')
    self._cancel_button = (By.CSS_SELECTOR, 'button.btn-blank')

  # POM Actions
  def validate_cas_signup_elements(self):
    """
    Validates elements of the CAS login page as wired into Aperta.
    :return: None
    """
    welcome_msg = self._get(self._welcome_message)
    assert welcome_msg.text == 'Join the PLOS Community', welcome_msg.text
    sign_in_link = self._get(self._signin_link)
    assert 'Sign In' in sign_in_link.text, sign_in_link.text
    forgot_pw_link = self._get(self._forgot_pw_link)
    assert forgot_pw_link.text == 'Forgot Password?'
    cas_resend_confirm = self._get(self._resend_confirm_email_link)
    assert cas_resend_confirm.text == 'Resend my email confirmation', cas_resend_confirm.text

    assert self._get(self._email_textbox_label).text == 'Email', self._get(self._email_textbox_label).text
    self._get(self._email_textbox)
    assert self._get(self._fname_textbox_label).text == 'First Name', self._get(self._fname_textbox_label).text
    self._get(self._lname_textbox)
    assert self._get(self._lname_textbox_label).text == 'Last Name', self._get(self._lname_textbox_label).text
    self._get(self._lname_textbox)
    assert self._get(self._password_textbox_label).text == 'Password', self._get(self._password_textbox_label).text
    self._get(self._password_textbox)
    assert self._get(self._confirm_password_textbox_label).text == 'Confirm Password', \
        self._get(self._confirm_password_textbox_label).text
    self._get(self._password_textbox)
    email_subscribe_msg = self._get(self._email_signup_label)
    assert 'I would like to receive occasional PLOS news updates.' in email_subscribe_msg.text, email_subscribe_msg.text
    assert not email_subscribe_msg.is_selected()
    create_account_btn = self._get(self._create_acct_button)
    assert 'Create Account' in create_account_btn.text
    cancel = self._get(self._cancel_button)
    assert cancel.text == 'Cancel', cancel.text

  def confirm_correct_url_form(self, environment_url):
    signup_urlform = self.get_current_url()
    signup_urlform = signup_urlform.split('=')[1]
    signup_urlform = urllib.unquote(signup_urlform)
    assert environment_url in signup_urlform

  def enter_login_field(self, email):
    """
    Inputs the Emailfor the test user
    :param email: email address
    :return: None
    """
    email_input = self._get(self._email_textbox)
    email_input.clear()
    email_input.send_keys(email)

  def enter_password_field(self, password):
    """
    Inputs the password for the test user
    :param password: password
    :return: None
    """
    pw_input = self._get(self._password_textbox)
    pw_input.clear()
    pw_input.send_keys(password)

  def click_sign_in_button(self):
    """
    Click the Sign-In button
    :return: None
    """
    cas_signin = self._get(self._signin_button)
    cas_signin.click()
