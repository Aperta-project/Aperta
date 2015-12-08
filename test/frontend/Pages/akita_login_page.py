#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Akita Login page.
"""

from selenium.webdriver.common.by import By

from Base.PlosPage import PlosPage

__author__ = 'jgray@plos.org'


class AkitaLoginPage(PlosPage):
  """
  Model an abstract Akita login page
  """
  def __init__(self, driver):
    super(AkitaLoginPage, self).__init__(driver, '')

    # Locators - Instance members
    self._welcome_message = (By.TAG_NAME, 'h1')
    self._email_textbox_label = (By.XPATH, '//label[@for="username"]')
    self._email_textbox = (By.ID, 'username')
    self._password_textbox_label = (By.XPATH, '//label[@for="password"]')
    self._password_textbox = (By.ID, 'password')
    self._forgot_pw_link = (By.CSS_SELECTOR, 'div.form-group a')
    self._remember_me_cb = (By.ID, 'rememberMe')
    self._remember_me_label = (By.CSS_SELECTOR, 'div#field_container + img + div.form-group')
    self._signin_button = (By.TAG_NAME, 'button')
    self._signup_link = (By.CSS_SELECTOR, 'div.content form + a')
    self._resend_confirm_email_link = (By.CSS_SELECTOR, 'div.content form + a + a')

  # POM Actions
  def validate_cas_login_elements(self):
    """
    Validates elements of the CAS login page as wired into Aperta.
    :return: None
    """
    welcome_msg = self._get(self._welcome_message)
    assert welcome_msg.text == 'Sign in to PLOS', welcome_msg.text
    assert self._get(self._email_textbox_label).text == 'Email', self._get(self._email_textbox_label).text
    self._get(self._email_textbox)
    assert self._get(self._password_textbox_label).text == 'Password', self._get(self._password_textbox_label).text
    self._get(self._password_textbox)
    forgot_msg = self._get(self._forgot_pw_link)
    assert forgot_msg.text == 'Forgot your password?'
    remember_cb = self._get(self._remember_me_cb)
    assert not remember_cb.is_selected()
    remember_msg = self._get(self._remember_me_label).text
    assert 'Remember me' in remember_msg
    cas_signin = self._get(self._signin_button)
    assert cas_signin.text == 'Sign In', cas_signin.text
    cas_signup = self._get(self._signup_link)
    assert 'Register for a New Account' in cas_signup.text, cas_signup.text
    cas_resend_confirm = self._get(self._resend_confirm_email_link)
    assert cas_resend_confirm.text == 'Resend e-mail address confirmation', cas_resend_confirm.text

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
