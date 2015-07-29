#!/usr/bin/env python2

from selenium.webdriver.common.by import By
from ...Base.PlosPage import PlosPage

__author__ = 'jgray@plos.org'


class LoginPage(PlosPage):
  """
  Model an abstract base login page
  """
  def __init__(self, driver):
    super(LoginPage, self).__init__(driver, '/users/sign_in')

    #Locators - Instance members
    self._welcome_message = (By.TAG_NAME, 'h1')
    self._login_textbox = (By.CSS_SELECTOR, '#user_login')
    self._password_textbox = (By.CSS_SELECTOR, '#user_password')
    self._forgot_pw_link = (By.TAG_NAME, 'a')
    self._remember_me_cb = (By.CSS_SELECTOR, 'input[type="checkbox"]')
    self._remember_me_label = (By.CSS_SELECTOR, 'label.auth-remember-me')
    self._signin_button = (By.CSS_SELECTOR, '#new_user > input.button-primary.button--green.auth-signin')
    self._signup_link = (By.CLASS_NAME, 'auth-signup')
    self._alert_text = (By.CLASS_NAME, 'auth-flash--alert')
    self._notice_text = (By.CLASS_NAME, 'auth-flash--notice')
    # target page locators
    self._loggedin_nav_toggle = (By.CLASS_NAME, 'navigation-toggle')
    self._loggedin_signout_link = (By.CSS_SELECTOR, 'div.navigation > a')


  #POM Actions
  def validate_initial_page_elements_styles(self):
    welcome_msg = self._get(self._welcome_message)
    assert welcome_msg.text == 'Welcome to Tahi'
    assert 'helvetica' in welcome_msg.value_of_css_property('font-family')
    assert welcome_msg.value_of_css_property('font-size') == '44px'
    assert welcome_msg.value_of_css_property('font-weight') == '400'
    assert welcome_msg.value_of_css_property('line-height') == '62.85px'
    assert welcome_msg.value_of_css_property('color') == 'rgba(0, 0, 0, 1)'
    forgot_msg = self._get(self._forgot_pw_link)
    assert forgot_msg.text == 'Forgot your password?'
    assert 'helvetica' in forgot_msg.value_of_css_property('font-family')
    assert forgot_msg.value_of_css_property('font-size') == '14px'
    assert forgot_msg.value_of_css_property('font-weight') == '400'
    assert forgot_msg.value_of_css_property('line-height') == '20px'
    assert forgot_msg.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'

    self._get(self._remember_me_cb)
    remember_msg = self._get(self._remember_me_label).text
    assert remember_msg == 'Remember me'
    self._get(self._signup_link)

  def enter_login_field(self, email):
    """Enter email"""
    self._get(self._login_textbox).clear()
    self._get(self._login_textbox).send_keys(email)

  def enter_password_field(self, password):
    """Entering password"""
    self._get(self._password_textbox).clear()
    self._get(self._password_textbox).send_keys(password)

  def click_sign_in_button(self):
    """Click Sign In button"""
    self._get(self._signin_button).click()

  def validate_signed_out_msg(self):
    signout_msg = self._get(self._notice_text)
    assert 'helvetica' in signout_msg.value_of_css_property('font-family')
    assert signout_msg.value_of_css_property('font-size') == '14px'
    assert signout_msg.value_of_css_property('font-weight') == '400'
    assert signout_msg.value_of_css_property('line-height') == '20px'
    assert signout_msg.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert signout_msg.value_of_css_property('background-color') == 'rgba(234, 253, 231, 1)'
    assert 'Signed out successfully.' in signout_msg.text  # where is there an extra span here?

  def validate_invalid_login_attempt(self):
    alert_msg = self._get(self._alert_text)
    assert 'Invalid email or password.' in alert_msg.text  # where is there an extra span here?
    assert 'helvetica' in alert_msg.value_of_css_property('font-family')
    assert alert_msg.value_of_css_property('font-size') == '14px'
    assert alert_msg.value_of_css_property('font-weight') == '400'
    assert alert_msg.value_of_css_property('line-height') == '20px'
    assert alert_msg.value_of_css_property('color') == 'rgba(133, 63, 89, 1)'
    assert alert_msg.value_of_css_property('background-color') == 'rgba(246, 239, 232, 1)'

  def sign_out(self):
    self._get(self._loggedin_nav_toggle).click()
    self._get(self._loggedin_signout_link).click()
