#!/usr/bin/env python2
# -*- coding: utf-8 -*-
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

    # Locators - Instance members
    self._profile_name_title = (By.XPATH, './/div["profile-section"]/h1')
    self._profile_name = (By.XPATH, './/div["profile-section"]/h2')
    self._profile_username_title = (By.XPATH, './/div[@id="profile-username"]/h1')
    self._profile_username = (By.XPATH, './/div[@id="profile-username"]/h2')
    self._profile_email_title = (By.XPATH, './/div[@id="profile-email"]/h1')
    self._profile_email = (By.XPATH, './/div[@id="profile-email"]/h2')
    self._profile_affiliation_title = (By.CSS_SELECTOR, 'div.user-affiliation h1')
    self._profile_link = (By.CSS_SELECTOR, 'div.profile-link a')
    self._affiliation_btn = (By.CSS_SELECTOR, 'a.button--green')
    self._reset_btn = (By.CSS_SELECTOR, 'a.reset-password-link')
    self._avatar = (By.XPATH, './/div[@id="profile-avatar"]/img')
    self._avatar_div = (By.XPATH, './/div[@id="profile-avatar"]')
    self._avatar_hover = (By.XPATH, './/div[@id="profile-avatar-hover"]/span')
    self._avatar_input = (By.CSS_SELECTOR, 'input[type="file"]')
    self._add_affiliation_title = (By.CSS_SELECTOR, 'div.affiliations-form h3')
    self._institution_input = (By.CSS_SELECTOR, 'div.affiliations-form div div input')
    self._department_input = (By.XPATH,
        ".//div[contains(@class, 'affiliations-form')]/div[2]/following-sibling::input")
    self._tile_input = (By.XPATH,
        ".//div[contains(@class, 'affiliations-form')]/div[2]/following-sibling::input[2]")
    self._country = (
        By.XPATH, ".//div[contains(@class, 'affiliations-form')]/div[3]/input")
    self._datepicker_1 = (
        By.XPATH, ".//div[contains(@class, 'affiliations-form')]/div[5]/div/input")
    self._datepicker_2 = (
        By.XPATH, ".//div[contains(@class, 'affiliations-form')]/div[5]/div/input[2]")
    self._email = (
        By.XPATH, ".//div[contains(@class, 'affiliations-form')]/div[5]/input")
    self._add_done_btn = (By.CSS_SELECTOR, 'div.affiliations-form button')
    self._add_cancel_btn = (By.CSS_SELECTOR, 'div.affiliations-form a')
    self._profile_affiliations = (By.CLASS_NAME, 'affiliation-existing')
    self._remove_affiliation_icon = (By.CLASS_NAME, 'affiliation-remove')
    self._success_message = (By.CSS_SELECTOR, 'div.success')
    self._error_message = (By.CLASS_NAME, 'error-message')
  # POM Actions

  @staticmethod
  def validate_profile_title_style_big(title):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    :param title: title to validate
    :return: None
    """
    # This needs to be reverted to use a formal style - the profile page is a style mess
    assert application_typeface in title.value_of_css_property('font-family')
    # https://www.pivotaltracker.com/story/show/103368442
    assert title.value_of_css_property('font-size') == '27px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '29.7px'
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    return None

  def validate_initial_page_elements_styles(self, username):
    """
    Validate initial page elements styles of Profile page
    :param username: User against which to validate profile page
    """
    # Validate menu elements (title and icon)
    name_title = self._get(self._profile_name_title)
    assert 'First and last name:' in name_title.text
    self.validate_profile_title_style(name_title)
    name = self._get(self._profile_name)
    self.validate_application_title_style(name)
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
    self.validate_secondary_big_green_button_style(affiliation_btn)
    avatar = self._get(self._avatar)
    self.validate_large_avatar_style(avatar)
    self._actions.move_to_element(self._get(self._avatar_div)).perform()
    time.sleep(1)
    avatar_hover = self._get(self._avatar_hover)
    assert avatar_hover.text == 'UPLOAD NEW'
    self.validate_large_avatar_hover_style(avatar_hover)
    profile_link = self._get(self._profile_link)
    assert profile_link.get_attribute('target') == '_blank'
    assert profile_link.get_attribute('href') == \
      'https://community.plos.org/account/edit-profile'
    self.validate_profile_link_style(profile_link)
    assert 'View or edit your full profile' in profile_link.text
    assert application_typeface in profile_link.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')

  def validate_invalid_add_new_affiliation(self):
    """
    Validate the error message for an invalid adding new affiliation.
    :return: None
    """
    # self.click_left_nav()
    self.click_add_affiliation_button()
    add_done_btn = self._get(self._add_done_btn)
    add_done_btn.click()
    # Watch for error
    error = self._get(self._error_message)
    assert error.text.lower() == "can't be blank", error.text
    # NOTE: Not validating error message style because lack of styleguide
    # Placeholder for error style validation:
    # assert error.value_of_css_property('font-size') == '12px'
    # assert error.value_of_css_property('font-weight') == '500'
    # assert error.value_of_css_property('line-height') == '29.7px'
    # assert error.value_of_css_property('color') == 'rgba(187 ,0 ,0 ,1)'

  def click_add_affiliation_button(self):
    """Click add addiliation button"""
    self._get(self._affiliation_btn).click()
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

  def validate_affiliation_form_css(self):
    """Validate css from add affiliation form"""
    add_aff_title = self._get(self._add_affiliation_title)
    assert 'helvetica' in add_aff_title.value_of_css_property('font-family')
    assert add_aff_title.text == 'New Affiliation'
    self.validate_application_h3_style(add_aff_title)
    # Note that the sytle guide is silent on this search selector style (APERTA-6358)
    institution_input = self._get(self._institution_input)
    # APERTA-6358 Commenting out until style implementation fixed.
    department_input = self._get(self._department_input)
    # APERTA-6358 Commenting out until style implementation fixed.
    # self.validate_input_field_style(department_input)
    title_input = self._get(self._tile_input)
    # APERTA-6358 Commenting out until style implementation fixed.
    # self.validate_input_field_style(title_input)
    country = self._get(self._country)
    # APERTA-6358 Commenting out until style implementation fixed.
    # self.validate_single_select_dropdown_style(country)
    datepicker_1 = self._get(self._datepicker_1)
    # Note that the sytle guide is silent on this date selector style (APERTA-6358)
    # self.validate_input_field_style(datepicker_1)
    datepicker_2 = self._get(self._datepicker_2)
    # Note that the sytle guide is silent on this date selector style (APERTA-6358)
    # self.validate_input_field_style(datepicker_2)
    email = self._get(self._email)
    # APERTA-6358 Commenting out until style implementation fixed.
    # self.validate_input_field_style(email)
    add_done_btn = self._get(self._add_done_btn)
    # APERTA-6358 Commenting out until style implementation fixed.
    # self.validate_secondary_big_green_button_style(add_done_btn)
    add_cancel_btn = self._get(self._add_cancel_btn)
    self.validate_default_link_style(add_cancel_btn)
    # Insert affiliation data
    institution_input.send_keys(affiliation['institution'])
    department_input.send_keys(affiliation['department'])
    title_input.send_keys(affiliation['title'])
    country.send_keys(affiliation['country'] + Keys.RETURN)
    time.sleep(.5)
    datepicker_1.send_keys(affiliation['start'] + Keys.RETURN)
    time.sleep(.5)
    datepicker_2.send_keys(affiliation['end'] + Keys.RETURN)
    time.sleep(.5)
    email.send_keys(affiliation['email'])
    time.sleep(.5)

    add_done_btn.send_keys(Keys.SPACE)
    # Look for data
    # Give some time to end AJAX call
    time.sleep(2)
    affiliations = self._gets(self._profile_affiliations)
    assert affiliation['institution'] in affiliations[-1].text, '{0} not in {1}'.format(
        affiliation['institution'], affiliations[-1].text)
    assert affiliation['department'] in affiliations[-1].text,  '{0} not in {1}'.format(
        affiliation['department'], affiliations[-1].text)
    assert affiliation['title'] in affiliations[-1].text, '{0} not in {1}'.format(
        affiliation['title'], affiliations[-1].text)
    assert affiliation['country'] in affiliations[-1].text, '{0} not in {1}'.format(
        affiliation['country'], affiliations[-1].text)
    assert affiliation['start'][-4:] in affiliations[-1].text, '{0} not in {1}'.format(
        affiliation['start'], affiliations[-1].text)
    assert affiliation['end'][-4:] in affiliations[-1].text, '{0} not in {1}'.format(
        affiliation['end'], affiliations[-1].text)
    assert affiliation['email'] in affiliations[-1].text, '{0} not in {1}'.format(
        affiliation['email'], affiliations[-1].text)
    remove_icons = self._gets(self._remove_affiliation_icon)
    remove_icons[-1].click()
    alert = self._driver.switch_to_alert()
    alert.accept()
    return self
