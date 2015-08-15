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
    self._profile_name_title = (By.XPATH, './/div["profile-section"]/h1')
    self._profile_name = (By.XPATH, './/div["profile-section"]/h2')
    self._profile_username_title = (By.XPATH, './/div[@id="profile-username"]/h1')
    self._profile_username = (By.XPATH, './/div[@id="profile-username"]/h2')
    self._profile_email_title = (By.XPATH, './/div[@id="profile-email"]/h1')
    self._profile_email = (By.XPATH, './/div[@id="profile-email"]/h2')
    self._profile_affiliation_title = (By.XPATH, './/div["col-md-10"]/div[4]/h1')
    self._affiliation_btn = (By.XPATH, './/div["col-md-10"]/div[4]/a')

  #POM Actions


  def validate_initial_page_elements_styles(self, username):
    """Validate initial page elements styles of Profile page"""
    # Validate menu elements (title and icon)
    self.click_left_nav()
    self.validate_nav_elements(username)
    # Close nav bar
    self.click_left_nav()
    name_title = self._get(self._profile_name_title)
    assert 'First and last name:' in name_title.text
    self.validate_profile_title_style(name_title)
    name = self._get(self._profile_name)
    self.validate_title_style(name)
    username_title = self._get(self._profile_username_title)
    assert 'Username:' in username_title.text
    self.validate_profile_title_style(username_title)
    profile_username = self._get(self._profile_username)
    self.validate_title_style(profile_username, '27', '29.7')
    email_title = self._get(self._profile_email_title)
    assert 'Email:' in email_title.text
    self.validate_profile_title_style(email_title)
    email = self._get(self._profile_email)
    self.validate_title_style(email, '27', '29.7')
    profile_at = self._get(self._profile_affiliation_title)
    assert 'Affiliations:' in profile_at.text
    self.validate_profile_title_style(profile_at)
    affiliation_btn = self._get(self._affiliation_btn)
    self.validate_grey_secondary_button_style(affiliation_btn)

    ##

    return self

  def click_reviewer_recommendation_button(self):
    """Click reviewer recommendation button"""
    self._get(self._reviewer_recommendation_button).click()
    return self


  def click_close_navigation(self):
    """Click on the close icon to close left navigation bar"""
    self._get(self._nav_close).click()
    return self


