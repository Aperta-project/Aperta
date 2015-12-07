#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the ORCID Login page.
"""

from selenium.webdriver.common.by import By

from Base.PlosPage import PlosPage

__author__ = 'jgray@plos.org'


class OrcidLoginPage(PlosPage):
  """
  Model an abstract ORCID login page
  """
  def __init__(self, driver):
    super(OrcidLoginPage, self).__init__(driver, '')

    # Locators - Instance members
    self._orcid_logo = (By.CSS_SELECTOR, 'div.logo h1 a img')
    self._orcid_authorize_btn = (By.ID, 'register-form-authorize')

  # POM Actions
  def validate_orcid_login_elements(self):
    """
    Validates elements of the ORCID login page as wired into Aperta.
    :return: None
    """
    self._get(self._orcid_logo)
    self._get(self._orcid_authorize_btn)
