#!/usr/bin/env python2

import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from authenticated_page import AuthenticatedPage


__author__ = 'sbassi@plos.org'


class ProfilePage(AuthenticatedPage):
  """
  Model workflow page
  """
  def __init__(self, driver):
    super(ProfilePage, self).__init__(driver, '/')

    #Locators - Instance members
    self._click_editor_assignment_button = (By.XPATH, './/div[2]/div[2]/div/div[4]/div')
  #POM Actions


  def validate_initial_page_elements_styles(self, username):
    """Validate initial page elements styles of Profile page"""
    # Validate menu elements (title and icon)
    self.click_left_nav()
    self.validate_nav_elements(username)
    # Close nav bar
    self.click_left_nav()
    

    return self

  def click_reviewer_recommendation_button(self):
    """Click reviewer recommendation button"""
    self._get(self._reviewer_recommendation_button).click()
    return self


  def click_close_navigation(self):
    """Click on the close icon to close left navigation bar"""
    self._get(self._nav_close).click()
    return self


