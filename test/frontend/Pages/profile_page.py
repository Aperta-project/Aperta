#!/usr/bin/env python2

import time
import os

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from authenticated_page import AuthenticatedPage, application_typeface
from Base.Resources import affiliation


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
    self._reset_btn = (By.CSS_SELECTOR, 'a.reset-password-link')
    self._avatar = (By.XPATH, './/div[@id="profile-avatar"]/img')
    self._avatar_div = (By.XPATH, './/div[@id="profile-avatar"]')
    self._avatar_hover = (By.XPATH, './/div[@id="profile-avatar-hover"]/span')
    self._avatar_input = (By.CSS_SELECTOR, 'input[type="file"]')
    self._add_affiliation_title = (By.CSS_SELECTOR, 'div.profile-affiliations-form h3')
    self._institution_input = (By.XPATH,
        ".//div[contains(@class, 'profile-affiliations-form')]/div/div/div/input")
    self._department_input = (By.XPATH,
        ".//div[contains(@class, 'profile-affiliations-form')]/input")
    self._tile_input = (By.XPATH,
        ".//div[contains(@class, 'profile-affiliations-form')]/input[2]")
    self._country = (By.XPATH,
        ".//div[contains(@class, 'profile-affiliations-form')]/div[3]/input")
    self._datepicker_1 = (By.XPATH,
        ".//div[contains(@class, 'profile-affiliations-form')]/div[5]/div/input")
    self._datepicker_2 = (By.XPATH,
        ".//div[contains(@class, 'profile-affiliations-form')]/div[5]/div/input[2]")
    self._email = (By.XPATH,
        ".//div[contains(@class, 'profile-affiliations-form')]/div[5]/input")
    self._add_done_btn = (By.XPATH,
        ".//div[contains(@class, 'profile-affiliations-form')]/button")
    self._add_cancel_btn = (By.XPATH,
        ".//div[contains(@class, 'profile-affiliations-form')]/a")
    self._profile_affiliations = (By.CSS_SELECTOR, 'div.profile-affiliation')
    self._remove_affiliation_icon = (By.CSS_SELECTOR, 'div.profile-remove-affiliation')
    self._success_message = (By.CSS_SELECTOR, 'div.success')

  #POM Actions

  @staticmethod
  def validate_profile_title_style_big(title):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    :param title: title to validate
    :return: None
    """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '27px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '29.7px'
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    return None

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
    self.validate_application_h1_style(name)
    username_title = self._get(self._profile_username_title)
    assert 'Username:' in username_title.text
    self.validate_profile_title_style(username_title)
    username = self._get(self._profile_username)
    self.validate_profile_title_style_big(username)
    email_title = self._get(self._profile_email_title)
    assert 'Email:' in email_title.text
    self.validate_profile_title_style(email_title)
    email = self._get(self._profile_email)
    self.validate_profile_title_style_big(email)
    profile_at = self._get(self._profile_affiliation_title)
    assert 'Affiliations:' in profile_at.text
    self.validate_profile_title_style(profile_at)
    affiliation_btn = self._get(self._affiliation_btn)
    self.validate_secondary_grey_small_button_style(affiliation_btn)
    reset_btn = self._get(self._reset_btn)
    self.validate_secondary_green_button_style(reset_btn)
    avatar = self._get(self._avatar)
    avatar.value_of_css_property('height') == '160px'
    avatar.value_of_css_property('width') == '160px'
    self._actions.move_to_element(self._get(self._avatar_div)).perform()
    time.sleep(1)
    avatar_hover = self._get(self._avatar_hover)
    assert avatar_hover.text == 'UPLOAD NEW'
    assert avatar_hover.value_of_css_property('font-size') == '14px'
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

  def validate_image_upload(self):
    """Validate uploading a new image as profile avatar"""
    # TODO: Check this when Pivotal#101632186 is fixed.
    self._actions.move_to_element(self._get(self._avatar_div)).perform()
    self._get(self._avatar_hover).click()
    avatar_input = self._iget(self._avatar_input)
    time.sleep(2)
    avatar_input.clear()
    time.sleep(2)
    avatar_input.send_keys(os.path.join(os.getcwd(),
                           "/frontend/assets/imgs/plos.gif" + Keys.RETURN + Keys.RETURN))
    time.sleep(1)
    return self

  def validate_reset_password(self):
    """Validate reset password button"""
    reset_btn = self._get(self._reset_btn)
    reset_btn.click()
    time.sleep(3)
    message = self._get(self._success_message).text
    assert "Reset password instructions have been sent to the your email address." in message

  def validate_affiliation_form_css(self):
    """Validate css from add affiliation form"""
    add_aff_title = self._get(self._add_affiliation_title)
    assert 'helvetica' in add_aff_title.value_of_css_property('font-family')
    assert add_aff_title.text == 'New Affiliation'
    assert add_aff_title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    assert add_aff_title.value_of_css_property('font-size') == '24px'
    institution_input = self._get(self._institution_input)
    self.validate_input_form_style(institution_input)
    department_input = self._get(self._department_input)
    self.validate_input_form_style(department_input)
    title_input = self._get(self._tile_input)
    self.validate_input_form_style(title_input)
    country = self._get(self._country)
    # TODO: Following method is here until bug #102008802 is fixed
    self.validate_input_form_style(country, color='rgba(51, 51, 51, 1)')
    datepicker_1 = self._get(self._datepicker_1)
    self.validate_input_form_style(datepicker_1)
    datepicker_2 = self._get(self._datepicker_2)
    self.validate_input_form_style(datepicker_2)
    email = self._get(self._email)
    self.validate_input_form_style(email)
    add_done_btn = self._get(self._add_done_btn)
    self.validate_secondary_green_button_style(add_done_btn)
    add_cancel_btn = self._get(self._add_cancel_btn)
    self.validate_default_link_style(add_cancel_btn)
    # Insert affiliation data
    institution_input.send_keys(affiliation['institution'])
    department_input.send_keys(affiliation['department'])
    title_input.send_keys(affiliation['title'])
    country.send_keys(affiliation['country'] + Keys.RETURN)
    time.sleep(1)
    datepicker_1.send_keys(affiliation['start'] + Keys.RETURN)
    time.sleep(2)
    datepicker_2.send_keys(affiliation['end'] + Keys.RETURN)
    time.sleep(2)
    email.send_keys(affiliation['email'])
    add_done_btn.click()
    # Look for data
    # Give some time to end AJAX call
    time.sleep(2)
    affiliations = self._gets(self._profile_affiliations)
    assert affiliation['institution'] in affiliations[-1].text
    assert affiliation['department'] in affiliations[-1].text
    assert affiliation['title'] in affiliations[-1].text
    assert affiliation['country'] in affiliations[-1].text
    assert affiliation['start'][-4:] in affiliations[-1].text
    assert affiliation['end'][-4:] in affiliations[-1].text
    assert affiliation['email'] in affiliations[-1].text
    remove_icons = self._gets(self._remove_affiliation_icon)
    remove_icons[-1].click()
    alert = self._driver.switch_to_alert()
    alert.accept()
    # TODO: Validate errors after #101686744 and #101686944 are fixed
    return self
