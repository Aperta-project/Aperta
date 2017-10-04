#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the ORCID Login page.
"""
import logging
import time

from selenium.webdriver.common.by import By

from Base.PlosPage import PlosPage
from Base.Resources import login_valid_pw

__author__ = 'jgray@plos.org'


class OrcidLoginPage(PlosPage):
  """
  Model an abstract ORCID login page
  """
  def __init__(self, driver):
    super(OrcidLoginPage, self).__init__(driver)

    # Locators - Instance members
    self._orcid_logo = (By.CSS_SELECTOR, 'div.logo h1 a img')
    # These next two are a misery or relations, but we don't own the page, ORCID does.
    self._orcid_user_input = (By.CSS_SELECTOR, '.personal-login > div > label + input')
    self._orcid_pw = (By.CSS_SELECTOR, '.personal-login > div + div > label + input')
    self._orcid_login_authorize_btn = (By.ID, 'login-authorize-button')

  # POM Actions
  def page_ready(self):
    """
    Ensure the page is ready for interaction
    :return: void function
    """
    self._wait_for_element(self._get(self._orcid_login_authorize_btn))

  def validate_orcid_login_elements(self):
    """
    Validates elements of the ORCID login page as wired into Aperta.
    :return: None
    """
    self._get(self._orcid_logo)
    self._get(self._orcid_user_input)
    self._get(self._orcid_pw)
    self._get(self._orcid_login_authorize_btn)

  def authorize_user(self, user):
    """
    Processes the ORCID authorization for user
    :param user: the user dictionary from Base/Resources to login
    :return: void function
    """
    email_input = self._get(self._orcid_user_input)
    email_input.send_keys(user['email'])
    pw = self._get(self._orcid_pw)
    pw.send_keys(login_valid_pw)
    authorize_btn = self._get(self._orcid_login_authorize_btn)
    authorize_btn.click()
    # ORCID Needs time to do its thing.
    time.sleep(5)
    self.traverse_from_window()

  def clean_orcid_cookies(self):
    # Clean up function
    current_url = self.get_current_url()
    self._driver.get('https://sandbox.orcid.org')
    self._driver.navigated = True
    all_cookies = self._driver.get_cookies()
    logging.info(u'Here are all the cookies prior to deletion: {0}'.format(all_cookies))
    # We MUST clean up ORCID cookies between logins or else everyone gets the same orcidID
    self._driver.delete_all_cookies()
    all_cookies = self._driver.get_cookies()
    logging.info(u'Here are all the cookies after deletion: {0}'.format(all_cookies))
    time.sleep(3)
    self._driver.get(current_url)
    self._driver.navigated = True
