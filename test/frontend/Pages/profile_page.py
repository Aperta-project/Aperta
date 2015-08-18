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
    self._affiliation_btn = (By.CSS_SELECTOR, 'a.button--grey')
    self._reset_btn = (By.XPATH, './/div["col-md-10"]/a')
    self._avatar = (By.XPATH, './/div[@id="profile-avatar"]/img')
    self._avatar_div = (By.XPATH, './/div[@id="profile-avatar"]')
    self._avatar_hover = (By.XPATH, './/div[@id="profile-avatar-hover"]')
    self._add_affiliation_title = (By.CSS_SELECTOR, 'div.profile-affiliations-form h3')
  #POM Actions


  def validate_initial_page_elements_styles(self, username):
    """Validate initial page elements styles of Profile page"""
    # Validate menu elements (title and icon)
    self.click_left_nav()
    self.validate_nav_elements(username)
    # Close nav bar
    self.click_nav_close()
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
    self.validate_secondary_button_style(affiliation_btn, color='rgba(119, 119, 119, 1)')
    reset_btn = self._get(self._reset_btn)
    self.validate_secondary_button_style(reset_btn, line_height='21.4333px', font_size='15px', 
                                         transform='capitalize', background_color='transparent',
                                         text_align='start')
    avatar = self._get(self._avatar)
    avatar.value_of_css_property('height') == '160px'
    avatar.value_of_css_property('width') == '160px'    
    self._actions.move_to_element(self._get(self._avatar_div)).perform()
    time.sleep(1)
    avatar_hover = self._get(self._avatar_hover)
    assert avatar_hover.text == 'UPLOAD NEW'
    assert avatar_hover.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    assert avatar_hover.value_of_css_property('font-size') == '14px'
    assert avatar_hover.value_of_css_property('background-color') == 'rgba(0, 145, 0, 0.8)'
    assert 'helvetica' in avatar_hover.value_of_css_property('font-family')
    return self

  def click_reviewer_recommendation_button(self):
    """Click reviewer recommendation button"""
    self._get(self._reviewer_recommendation_button).click()
    return self

  def click_add_affiliation_button(self):
    """Click add addiliation button"""
    self._get(self._affiliation_btn).click()
    return self

  def click_close_navigation(self):
    """Click on the close icon to close left navigation bar"""
    self._get(self._nav_close).click()
    return self

  def validate_affiliation_form_css(self):
    """Validate css from add affiliation form"""
    assert self._get(self._add_affiliation_title)
    return self

