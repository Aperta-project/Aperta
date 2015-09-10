#!/usr/bin/env python2

import pdb

from selenium.webdriver.common.by import By
from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class AuthorsCard(BaseCard):
  """
  Page Object Model for Authors Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(AuthorsCard, self).__init__(driver)

    #Locators - Instance members
    self._click_task_completed = (By.CSS_SELECTOR, '#task_completed')
    self._close_button_bottom = (By.CSS_SELECTOR, 'footer > div > a.button-secondary')



   #POM Actions
  def click_task_completed_checkbox(self):
    """Click task completed checkbox"""
    self._get(self._click_task_completed).click()
    return self

  def click_close_button_bottom(self):
    """Click close button on bottom"""
    self._get(self._close_button_bottom).click()
    return self

  def validate_styles(self):
    """Validate all styles for Authors Card"""
    # validate elements that are common to all cards
    self.validate_common_elements_styles()




    return self
