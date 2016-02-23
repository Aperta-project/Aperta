#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Login page and the Forgot Your Password page.
"""

import logging
import time

from selenium.webdriver.common.by import By

from authenticated_page import AuthenticatedPage, application_typeface, tahi_green, white

__author__ = 'jgray@plos.org'


class LoginPage(AuthenticatedPage):
  """
  Model an abstract base login page
  Note that while these are unauthenticated pages, inheriting from them makes style validation across the application
  more consistent.
  """
  def __init__(self, driver):
    super(LoginPage, self).__init__(driver, '/users/sign_in')

    # Locators - Instance members
    self._welcome_message = (By.TAG_NAME, 'h1')
    self._login_textbox = (By.CSS_SELECTOR, '#user_login')
    self._password_textbox = (By.CSS_SELECTOR, '#user_password')
    self._forgot_pw_link = (By.TAG_NAME, 'a')
    self._remember_me_cb = (By.CSS_SELECTOR, 'input[type="checkbox"]')
    self._remember_me_label = (By.CSS_SELECTOR, 'label.auth-remember-me')
    self._signin_button = (By.CSS_SELECTOR, '#new_user > input.button-primary.button--green.auth-signin')
    self._signup_link = (By.CLASS_NAME, 'auth-signup')
    # CAS Related items
    self._cas_signin = (By.CSS_SELECTOR, 'div.auth-right a.auth-cas')
    self._cas_signup = (By.CSS_SELECTOR, 'div.auth-right a.auth-cas + a.auth-cas')
    # ORCID Related items
    self._orcid_signin = (By.CSS_SELECTOR, 'div.auth-right a.auth-orcid')
    # Flash messaging
    self._alert_text = (By.CLASS_NAME, 'auth-flash--alert')
    self._notice_text = (By.CLASS_NAME, 'auth-flash--notice')
    # dashboard page locators
    self._loggedin_nav_toggle = (By.ID, 'profile-dropdown-menu')
    self._loggedin_signout_link = (By.ID, 'nav-signout')
    # forgot pw page locators
    self._fyp_title = (By.TAG_NAME, 'h1')
    self._fyp_email_field = (By.ID, 'user_email')
    self._fyp_send_reset_btn = (By.CSS_SELECTOR, 'input.button--green')
    self._fyp_signin_btn = (By.CSS_SELECTOR, 'a.button--grey')
    self._fyp_error = (By.CSS_SELECTOR, '#error_explanation ul li')

  # POM Actions
  def validate_initial_page_elements_styles(self):
    """
    Validates elements and styles of the login page and the Forgot Your Password page.
    :return: None
    """
    welcome_msg = self._get(self._welcome_message)
    assert welcome_msg.text == 'Welcome to Aperta', welcome_msg.text
    # APERTA-6107 Filed for the following
    # self.validate_application_title_style(welcome_msg)
    # inside the app, it seems we use a dark grey (51, 51, 51) Why is this different?
    assert welcome_msg.value_of_css_property('color') == 'rgba(0, 0, 0, 1)'
    forgot_msg = self._get(self._forgot_pw_link)
    assert forgot_msg.text == 'Forgot your password?'
    self.validate_default_link_style(forgot_msg)
    remember_cb = self._get(self._remember_me_cb)
    assert not remember_cb.is_selected()
    self._get(self._remember_me_cb)
    remember_msg = self._get(self._remember_me_label).text
    assert remember_msg == 'Remember me'
    self._get(self._signup_link)
    cas_signin = self._get(self._cas_signin)
    # APERTA-5717
    # self.validate_primary_big_blue_button_style(cas_signin)
    cas_signup = self._get(self._cas_signup)
    # APERTA-5717
    # self.validate_secondary_big_green_button_style(cas_signup)
    orcid_signin = self._get(self._orcid_signin)
    # APERTA-5717
    # self.validate_primary_big_green_button_style(orcid_signin)

  def enter_login_field(self, username):
    """
    Inputs the Email or Username for the test user
    :param email: email address or username
    :return: None
    """
    self._get(self._login_textbox).clear()
    logging.info('Login as {}'.format(username))
    self._get(self._login_textbox).send_keys(username)

  def enter_password_field(self, password):
    """
    Inputs the password for the test user
    :param password: password
    :return: None
    """
    self._get(self._password_textbox).clear()
    self._get(self._password_textbox).send_keys(password)

  def click_sign_in_button(self):
    """
    Click the Sign-In button
    :return: None
    """
    self._get(self._signin_button).click()

  def validate_signed_out_msg(self):
    """
    Validate the sign out message and its style
    :return: None
    """
    signout_msg = self._get(self._notice_text)
    assert 'helvetica' in signout_msg.value_of_css_property('font-family')
    assert signout_msg.value_of_css_property('font-size') == '14px'
    assert signout_msg.value_of_css_property('font-weight') == '400'
    assert signout_msg.value_of_css_property('line-height') == '20px'
    assert signout_msg.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert signout_msg.value_of_css_property('background-color') == 'rgba(234, 253, 231, 1)'
    assert 'Signed out successfully.' in signout_msg.text  # why is there an extra span here?

  def validate_reset_pw_msg(self):
    """
    Validate the Reset Password Sent message and its style
    :return: None
    """
    reset_msg = self._get(self._notice_text)
    assert 'helvetica' in reset_msg.value_of_css_property('font-family')
    assert reset_msg.value_of_css_property('font-size') == '14px'
    assert reset_msg.value_of_css_property('font-weight') == '400'
    assert reset_msg.value_of_css_property('line-height') == '20px'
    assert reset_msg.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert reset_msg.value_of_css_property('background-color') == 'rgba(234, 253, 231, 1)'
    assert 'You will receive an email with instructions about how to reset your password in a few minutes.' \
           in reset_msg.text  # why is there an extra span here?

  def validate_invalid_login_attempt(self):
    """
    Validate the error message for an invalid login attempt
    :return: None
    """
    alert_msg = self._get(self._alert_text)
    assert 'Invalid email or password.' in alert_msg.text  # why is there an extra span here?
    self.validate_flash_error_style(alert_msg)

  def enter_fyp_field(self, email):
    """
    Enters and email address for test user into the forgot your password field
    :param email: email address
    :return: None
    """
    self._get(self._fyp_email_field).clear()
    self._get(self._fyp_email_field).send_keys(email)

  def click_sri_button(self):
    """
    Initiates the Send Reset Instructions function
    :return: None
    """
    self._get(self._fyp_send_reset_btn).click()

  def open_fyp(self):
    """
    Opens the Forgot Your Password Page
    :return: None
    """
    self._get(self._forgot_pw_link).click()

  def close_fyp(self):
    """
    Closes the Forgot your Password page, returning to the main Login page
    :return: None
    """
    signin_btn = self._get(self._fyp_signin_btn)
    signin_btn.click()

  def validate_fyp_elements_styles_function(self):
    """
    Validates the elements and their styles for the Forgot Your Password page, including error messaging.
    :return: None
    """
    pw_reset_ttl = self._get(self._fyp_title)
    assert pw_reset_ttl.text == 'Forgot your password?'
    # APERTA-6107 has been filed for the font-size mismatch
    # self.validate_application_title_style(pw_reset_ttl)
    email_input = self._get(self._fyp_email_field)
    assert email_input.get_attribute('placeholder') == 'Email'
    assert email_input.value_of_css_property('width') == '205px'
    assert email_input.value_of_css_property('line-height') == '18px'
    send_reset_btn = self._get(self._fyp_send_reset_btn)
    assert send_reset_btn.get_attribute('value') == 'Send reset instructions'
    self.validate_primary_big_green_button_style(send_reset_btn)
    send_reset_btn.click()
    fyp_error = self._get(self._fyp_error)
    assert fyp_error.text == "Email can't be blank"
    self.validate_flash_error_style(fyp_error)
    signin_btn = self._get(self._fyp_signin_btn)
    assert signin_btn.text == 'Sign in'
    #self.validate_primary_big_grey_button_style(signin_btn)

  def validate_fyp_email_fmt_error(self):
    """
    Validates the special styling of the email field when an error occurs. The field is highlighted
    in a light red shade.
    :return: None
    """
    email_field = self._get(self._fyp_email_field)
    # This error highlighting of the field seems unique in the whole application
    assert email_field.value_of_css_property('border-top-color') == 'rgba(204, 204, 205, 1)'
    assert email_field.value_of_css_property('border-bottom-color') == 'rgba(204, 204, 205, 1)'
    assert email_field.value_of_css_property('border-left-color') == 'rgba(204, 204, 205, 1)'
    assert email_field.value_of_css_property('border-right-color') == 'rgba(204, 204, 205, 1)'

  def click_remember_me(self):
    """
    Click the Remember Me checkbox, triggering a cookie to be set on Login.
    :return: None
    """
    self._get(self._remember_me_cb).click()

  def validate_remember_me(self, login, pw):
    """
    Validates the remember me function on the page insofar as the relevant cookie is set
    :param login: valid login string
    :param pw: valid pw string
    """
    cookie = self._driver.get_cookie('remember_user_token')
    assert not cookie
    self.enter_login_field(login)
    self.enter_password_field(pw)
    self.click_remember_me()
    self.click_sign_in_button()
    cookie = self._driver.get_cookie('remember_user_token')
    assert cookie

  def sign_out(self):
    """
    After sucessful Login, opens the Nav menu and logs out.
    :return: None
    """
    self._get(self._loggedin_nav_toggle).click()
    self._get(self._loggedin_signout_link).click()

  def login_cas(self):
    """Initiate a NED CAS Sign In request"""
    cas_signin = self._get(self._cas_signin)
    cas_signin.click()
    time.sleep(3)

  def signup_cas(self):
    """Initiate a NED CAS Sign Up request"""
    cas_signup = self._get(self._cas_signup)
    cas_signup.click()
    time.sleep(3)

  def login_orcid(self):
    """Initiate an ORCID Sign In request - Authorization to share login with Aperta"""
    orcid_signin = self._get(self._orcid_signin)
    orcid_signin.click()
    time.sleep(3)
