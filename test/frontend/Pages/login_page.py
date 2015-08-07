#!/usr/bin/env python2

from selenium.webdriver.common.by import By
from Base.PlosPage import PlosPage

__author__ = 'jgray@plos.org'


class LoginPage(PlosPage):
  """
  Model an abstract base login page
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
    self._alert_text = (By.CLASS_NAME, 'auth-flash--alert')
    self._notice_text = (By.CLASS_NAME, 'auth-flash--notice')
    # dashboard page locators
    self._loggedin_nav_toggle = (By.CLASS_NAME, 'navigation-toggle')
    self._loggedin_signout_link = (By.CSS_SELECTOR, 'div.navigation > a')
    # forgot pw page locators
    self._fyp_title = (By.TAG_NAME, 'h1')
    self._fyp_email_field = (By.ID, 'user_email')
    self._fyp_send_reset_btn = (By.CSS_SELECTOR, 'input.button--green')
    self._fyp_signin_btn = (By.CSS_SELECTOR, 'a.button--grey')
    self._fyp_error = (By.CSS_SELECTOR, '#error_explanation ul li')

  # POM Actions
  def validate_initial_page_elements_styles(self):
    welcome_msg = self._get(self._welcome_message)
    assert welcome_msg.text == 'Welcome to PLOS'
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
    remember_cb = self._get(self._remember_me_cb)
    assert not remember_cb.is_selected()
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
    assert 'Signed out successfully.' in signout_msg.text  # why is there an extra span here?

  def validate_reset_pw_msg(self):
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
    alert_msg = self._get(self._alert_text)
    assert 'Invalid email or password.' in alert_msg.text  # why is there an extra span here?
    assert 'helvetica' in alert_msg.value_of_css_property('font-family')
    assert alert_msg.value_of_css_property('font-size') == '14px'
    assert alert_msg.value_of_css_property('font-weight') == '400'
    assert alert_msg.value_of_css_property('line-height') == '20px'
    assert alert_msg.value_of_css_property('color') == 'rgba(133, 63, 89, 1)'
    assert alert_msg.value_of_css_property('background-color') == 'rgba(246, 239, 232, 1)'

  def enter_fyp_field(self, email):
    """Enter email"""
    self._get(self._fyp_email_field).clear()
    self._get(self._fyp_email_field).send_keys(email)

  def click_sri_button(self):
    """Click Send Reset instructions button"""
    self._get(self._fyp_send_reset_btn).click()

  def open_fyp(self):
    self._get(self._forgot_pw_link).click()

  def close_fyp(self):
    signin_btn = self._get(self._fyp_signin_btn)
    signin_btn.click()

  def validate_fyp_elements_styles_function(self):
    pw_reset_ttl = self._get(self._fyp_title)
    assert pw_reset_ttl.text == 'Forgot your password?'
    assert 'helvetica' in pw_reset_ttl.value_of_css_property('font-family')
    assert pw_reset_ttl.value_of_css_property('font-size') == '44px'
    assert pw_reset_ttl.value_of_css_property('font-weight') == '400'
    assert pw_reset_ttl.value_of_css_property('line-height') == '62.85px'
    assert pw_reset_ttl.value_of_css_property('text-align') == 'center'
    email_input = self._get(self._fyp_email_field)
    assert email_input.get_attribute('placeholder') == 'Email'
    assert email_input.value_of_css_property('width') == '205px'
    assert email_input.value_of_css_property('line-height') == '18px'
    send_reset_btn = self._get(self._fyp_send_reset_btn)
    assert send_reset_btn.get_attribute('value') == 'Send reset instructions'
    assert 'helvetica' in send_reset_btn.value_of_css_property('font-family')
    assert send_reset_btn.value_of_css_property('font-size') == '14px'
    assert send_reset_btn.value_of_css_property('font-weight') == '400'
    assert send_reset_btn.value_of_css_property('line-height') == '20px'
    assert send_reset_btn.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
    assert send_reset_btn.value_of_css_property('text-align') == 'center'
    assert send_reset_btn.value_of_css_property('text-transform') == 'uppercase'
    send_reset_btn.click()
    assert self._get(self._fyp_error).text == "Email can't be blank"
    signin_btn = self._get(self._fyp_signin_btn)
    assert signin_btn.text == 'Sign in'
    assert 'helvetica' in signin_btn.value_of_css_property('font-family')
    assert signin_btn.value_of_css_property('font-size') == '16px'
    assert signin_btn.value_of_css_property('font-weight') == '600'
    assert signin_btn.value_of_css_property('line-height') == '22.85px'
    assert signin_btn.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
    assert signin_btn.value_of_css_property('text-align') == 'center'
    assert signin_btn.value_of_css_property('vertical-align') == 'middle'

  def validate_fyp_email_fmt_error(self):
    email_field = self._get(self._fyp_email_field)
    assert email_field.value_of_css_property('border-top-color') == 'rgba(204, 204, 205, 1)'
    assert email_field.value_of_css_property('border-bottom-color') == 'rgba(204, 204, 205, 1)'
    assert email_field.value_of_css_property('border-left-color') == 'rgba(204, 204, 205, 1)'
    assert email_field.value_of_css_property('border-right-color') == 'rgba(204, 204, 205, 1)'

  def click_remember_me(self):
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
    self._get(self._loggedin_nav_toggle).click()
    self._get(self._loggedin_signout_link).click()
