#!/usr/bin/env python2

from selenium.webdriver.common.by import By
#from integration_tests.Base.PlosPage import PlosPage
from Base.PlosPage import PlosPage

__author__ = 'fcabrales'

class LoginPage(PlosPage):
  """
  Model an abstract base login page
  """
  def __init__(self, driver):
    super(LoginPage, self).__init__(driver, '/users/sign_in')

    #Locators - Instance members
    self._login_textbox = (By.CSS_SELECTOR, '#user_login')
    self._password_textbox = (By.CSS_SELECTOR, '#user_password')
    self._signin_button= (By.CSS_SELECTOR, '#new_user > input.button-primary.button--green.auth-signin')

  #POM Actions
  def enter_login_field(self, email):
    """Enter email"""
    self._get(self._login_textbox).clear()
    self._get(self._login_textbox).send_keys(email)
    return self

  def enter_password_field(self, password):
    """Entering password"""
    self._get(self._password_textbox).clear()
    self._get(self._password_textbox).send_keys(password)
    return self

  def click_sign_in_button(self):
    """Click Sign In button"""
    self._get(self._signin_button).click()
    return self
