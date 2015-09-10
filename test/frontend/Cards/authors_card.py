#!/usr/bin/env python2

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
    self._header_link = (By.CLASS_NAME, 'overlay-header-link')



   #POM Actions
  def click_task_completed_checkbox(self):
    """ Click task completed checkbox """
    self._get(self._click_task_completed).click()
    return self

  def click_close_button_bottom(self):
    """ Click close button on bottom """
    self._get(self._close_button_bottom).click()
    return self

  def check_styles(self):
    """ """
    
    return self
