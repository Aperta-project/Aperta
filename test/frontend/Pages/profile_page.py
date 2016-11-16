#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time
import os

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from authenticated_page import AuthenticatedPage, application_typeface
from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Resources import affiliation

__author__ = 'sbassi@plos.org'


class ProfilePage(AuthenticatedPage):
  """
  Model workflow page
  """
  def __init__(self, driver):
    super(ProfilePage, self).__init__(driver)

    # Locators - Instance members
    self._avatar = (By.XPATH, './/div[@id="profile-avatar"]/img')
    self._avatar_div = (By.XPATH, './/div[@id="profile-avatar"]')
    self._avatar_hover = (By.XPATH, './/div[@id="profile-avatar-hover"]/span')
    self._avatar_input = (By.CSS_SELECTOR, 'input[type="file"]')

    self._profile_name_title = (By.XPATH, './/div["profile-section"]/h1')
    self._profile_name = (By.XPATH, './/div["profile-section"]/h2')
    self._profile_username_title = (By.XPATH, './/div[@id="profile-username"]/h1')
    self._profile_username = (By.XPATH, './/div[@id="profile-username"]/h2')
    self._profile_email_title = (By.XPATH, './/div[@id="profile-email"]/h1')
    self._profile_email = (By.XPATH, './/div[@id="profile-email"]/h2')
    # ORCID Elements
    self._profile_orcid_div = (By.CLASS_NAME, 'orcid-connect')
    self._profile_orcid_logo = (By.ID, 'orcid-id-logo')
    self._profile_orcid_unlinked_div = (By.CLASS_NAME, 'orcid-not-linked')
    self._profile_orcid_unlinked_button = (By.CSS_SELECTOR, 'div.orcid-not-linked > button')
    self._profile_orcid_unlinked_help_icon = (By.CLASS_NAME, 'what-is-orcid')

    self._profile_orcid_linked_div = (By.CLASS_NAME, 'orcid-linked')
    self._profile_orcid_linked_title = (By.CSS_SELECTOR, 'div.orcid-linked')
    self._profile_orcid_linked_id_link = (By.CSS_SELECTOR, 'div.orcid-linked > a')
    self._profile_orcid_linked_delete_icon = (By.CSS_SELECTOR, 'div.orcid-linked > i.fa-trash')
    # Affiliation Elements
    # View Mode
    self._profile_affiliation_form_title = (By.CSS_SELECTOR, 'div.user-affiliation > h1')
    self._profile_affiliation_aff_text = (By.CSS_SELECTOR, 'div.user-affiliation > h1 + div')
    self._profile_affiliations = (By.CLASS_NAME, 'affiliation-existing')
    self._profile_affiliation_institution = (By.CLASS_NAME, 'profile-affiliation-name')
    self._profile_affiliation_delete = (By.CLASS_NAME, 'affiliation-remove')
    self._profile_affiliation_edit = (By.CSS_SELECTOR, 'span.action-icons > span.fa-pencil')
    self._profile_affiliation_dept = (By.CSS_SELECTOR, 'div.affiliation-existing > div > div')
    self._profile_affiliation_title = (By.CSS_SELECTOR,
                                       'div.affiliation-existing > div > div + div')
    self._profile_affiliation_country = (By.CSS_SELECTOR,
                                         'div.affiliation-existing > div > div + div + div')
    self._profile_affiliation_dates = (By.CSS_SELECTOR, 'div.affiliation-existing > div')
    self._profile_affiliation_email = (By.CSS_SELECTOR,
                                       'div.affiliation-existing > div + div + div')
    # Affiliation Edit Mode
    self._add_affiliation_form = (By.CLASS_NAME, 'affiliations-form')
    self._add_affiliation_form_title = (By.CSS_SELECTOR, 'div.affiliations-form h3')
    self._add_affiliation_form_subtext = (By.CSS_SELECTOR, 'div.affiliations-form > p')
    self._add_affiliation_institution_input = (By.CSS_SELECTOR,
                                               'div.affiliations-form div div input')
    self._add_affiliation_department_label = (By.CSS_SELECTOR, 'div.department > div > label')
    self._add_affiliation_department_field = (By.CSS_SELECTOR, 'div.department > input')
    self._add_affiliation_title_label = (By.CSS_SELECTOR,
                                         'div.department + div.department > div > label')
    self._add_affiliation_title_field = (By.CSS_SELECTOR, 'div.department + div.department > input')
    self._add_affiliation_country_drop_list_collapsed = (By.CLASS_NAME, 'select2-container')
    self._add_affiliation_country_input = (By.CSS_SELECTOR, 'input.select2-input')
    self._add_affiliation_country_list_items = (By.CSS_SELECTOR, 'li.select2-result-selectable')
    # # Following two selectors will be used until specific class is added (APERTA-7868)
    # self._affiliation_field = (By.CLASS_NAME, 'affiliation-field')
    self._add_affiliation_dates_label = (By.CSS_SELECTOR,
                                         'div.affiliations-form > div.form-group > h1')
    self._add_affiliation_start_date_field = (By.CSS_SELECTOR,
                                              'div.form-group > div > input.datepicker')
    self._add_affiliation_end_date_field = (By.CSS_SELECTOR, 'div.form-group > div > input + input')
    self._add_affiliation_datepicker_selector = (By.CLASS_NAME, 'datepicker-dropdown')
    self._add_affiliation_email_label = (By.CSS_SELECTOR, 'div.required.email > div > label')
    self._add_affiliation_email_field = (By.CSS_SELECTOR, 'div.required.email > input')

    self._add_affiliation_done_button = (By.CSS_SELECTOR, 'div.affiliations-form > button')
    self._add_affiliation_cancel_link = (By.CSS_SELECTOR, 'a.author-cancel')

    # This is present only for native, non-cas logins
    self._reset_btn = (By.CSS_SELECTOR, 'a.reset-password-link')

    self._add_new_affiliation_btn = (By.CSS_SELECTOR, 'div.user-affiliation a')
    self._cas_profile_link = (By.CSS_SELECTOR, 'div.profile-link a')
    self._cas_profile_ptext = (By.CLASS_NAME, 'profile-link')


  # POM Actions
  def page_ready(self):
    """
    A method to validate that the profile page has fully loaded. At time of this writing, it
      appears as if the orcid information is drawing last. I suspect this will change at some point.
    :return:  void function
    """
    self._wait_for_element(self._get(self._profile_orcid_div))

  def validate_initial_page_elements_styles(self, username):
    """
    Validate page elements styles of Profile page. Note that there are two chunks of conditional
      elements here: 1) if orcid is linked/unlinked; and 2) if there are/are not affiliations
    :param username: User against which to validate profile page
    """
    avatar = self._get(self._avatar)
    self.validate_large_avatar_style(avatar)
    self._actions.move_to_element(self._get(self._avatar_div)).perform()
    time.sleep(.5)
    avatar_hover = self._get(self._avatar_hover)
    assert avatar_hover.text == 'UPLOAD NEW'
    self.validate_large_avatar_hover_style(avatar_hover)

    name_title = self._get(self._profile_name_title)
    assert 'First and last name:' in name_title.text

    name = self._get(self._profile_name)
    assert username['name'] == name.text, 'Requested user: {0} not found on ' \
                                         'page: {1}'.format(username['name'], name.text)
    self.validate_application_title_style(name)

    username_title = self._get(self._profile_username_title)
    assert 'Username:' in username_title.text

    page_username = self._get(self._profile_username)
    assert username['user'] == page_username.text, u'Requested user: {0} not found on ' \
                                                   u'page: {1}'.format(username['user'],
                                                                       page_username.text)

    email_title = self._get(self._profile_email_title)
    assert 'Email:' in email_title.text

    page_email = self._get(self._profile_email)
    assert username['email'] == page_email.text, u'Requested user: {0} not found on ' \
                                                 u'page: {1}'.format(username['email'],
                                                                     page_email.text)
    unlinked = False
    orcid_logo = self._get(self._profile_orcid_logo)
    assert orcid_logo.get_attribute('src') == \
        'http://orcid.org/sites/default/files/images/orcid_24x24.png', \
        orcid_logo.get_attribute('src')
    assert orcid_logo.get_attribute('alt') == 'ORCID logo', orcid_logo.get_attribute('alt')
    assert orcid_logo.get_attribute('width') == u'24', orcid_logo.get_attribute('width')
    assert orcid_logo.get_attribute('height') == u'24', orcid_logo.get_attribute('height')
    self.set_timeout(3)
    try:
      self._get(self._profile_orcid_linked_div)
    except ElementDoesNotExistAssertionError:
      unlinked = True
      self._get(self._profile_orcid_unlinked_div)
    if unlinked:
      orcid_btn = self._get(self._profile_orcid_unlinked_button)
      assert 'CONNECT OR CREATE YOUR ORCID ID' in orcid_btn.text, orcid_btn.text
      orcid_help_icon = self._get(self._profile_orcid_unlinked_help_icon)
      assert orcid_help_icon.get_attribute('href') == 'https://plos.org/orcid', \
          orcid_help_icon.get_attribute('href')
      assert orcid_help_icon.get_attribute('target') == '_blank', \
          orcid_help_icon.get_attribute('target')
    else:
      oid_title = self._get(self._profile_orcid_linked_title)
      assert oid_title.text == 'ORCID ID:', oid_title.text
      oid_link = self._get(self._profile_orcid_linked_id_link)
      assert oid_link.text == username['orcidid'], oid_link.text
      assert oid_link.get_attribute('target') == '_blank', oid_link.get_attribute('target')
      oid_href = 'http://sandbox.orcid.org/' + oid_link.text
      assert oid_link.get_attribute('href') == oid_href, 'Orcid link on page: {0} != expected ' \
                                                         'link: {1}'\
          .format(oid_link.get_attribute('href'), oid_href)

      self._get(self._profile_orcid_linked_delete_icon)

    existing_affiliation = True
    # Validate common affiliation elements
    affiliation_btn = self._get(self._add_new_affiliation_btn)
    self.validate_secondary_big_green_button_style(affiliation_btn)
    profile_affiliation_form_title = self._get(self._profile_affiliation_form_title)
    profile_link = self._get(self._cas_profile_link)
    assert profile_link.get_attribute('target') == '_blank'
    assert profile_link.get_attribute('href') == \
        'https://community.plos.org/account/edit-profile'
    self.validate_profile_link_style(profile_link)
    assert 'View or edit your full profile' in profile_link.text
    assert application_typeface in profile_link.value_of_css_property('font-family'), \
        profile_link.value_of_css_property('font-family')
    assert 'Affiliations:' in profile_affiliation_form_title.text
    try:
      self._get(self._profile_affiliations)
    except ElementDoesNotExistAssertionError:
      existing_affiliation = False
      no_aff_text = self._get(self._profile_affiliation_aff_text)
      # APERTA-8178 Typo
      # assert no_aff_text.text == 'No affiliations yet', no_aff_text.text
    if not existing_affiliation:
      affiliation_btn.click()
      self._wait_for_element(self._get(self._add_affiliation_form))
      add_form_title = self._get(self._add_affiliation_form_title)
      assert add_form_title.text =='New Affiliation', add_form_title.text
      add_form_subtext = self._get(self._add_affiliation_form_subtext)
      assert add_form_subtext.text == 'Enter most recent affiliations first', add_form_subtext.text
      institution_field = self._get(self._add_affiliation_institution_input)
      assert institution_field.get_attribute('placeholder') == 'Institution', \
          institution_field.get_attribute('placeholder')
      department_label = self._get(self._add_affiliation_department_label)
      assert department_label.text == 'Department', department_label.text
      department_field = self._get(self._add_affiliation_department_field)
      assert department_field.get_attribute('placeholder') == 'Department', \
          department_field.get_attribute('placeholder')
      title_label = self._get(self._add_affiliation_title_label)
      assert title_label.text == 'Title', title_label.text
      title_field = self._get(self._add_affiliation_title_field)
      assert title_field.get_attribute('placeholder') == 'Title', \
          title_field.get_attribute('placeholder')
      country_dropdown = self._get(self._add_affiliation_country_drop_list_collapsed)
      assert country_dropdown.text == 'Country', country_dropdown.text
      country_dropdown.click()
      self._get(self._add_affiliation_country_input)
      country_list = self._gets(self._add_affiliation_country_list_items)
      country_text_list = []
      for country in country_list:
        country_text_list.append(country.text)
      assert 'Cocos (Keeling) Islands' in country_text_list, 'Not properly populating country ' \
                                                             'list from NED!'
      country_dropdown.click()
      affiliation_dates_label = self._get(self._add_affiliation_dates_label)
      assert 'time at institution:' in affiliation_dates_label.text, affiliation_dates_label.text
      start_date_field = self._get(self._add_affiliation_start_date_field)
      assert start_date_field.get_attribute('placeholder') == 'Start Date', \
          start_date_field.get_attribute('placeholder')
      end_date_field = self._get(self._add_affiliation_end_date_field)
      assert end_date_field.get_attribute('placeholder') == 'End Date', \
          end_date_field.get_attribute('placeholder')
      start_date_field.click()
      self._get(self._add_affiliation_datepicker_selector)
      end_date_field.click()
      self._get(self._add_affiliation_datepicker_selector)
      affiliation_email_lbl = self._get(self._add_affiliation_email_label)
      assert affiliation_email_lbl.text == 'Email Address', affiliation_email_lbl.text
      assert 'required' in affiliation_email_lbl.get_attribute('class'), \
          affiliation_email_lbl.get_attribute('class')
      affiliation_email_field = self._get(self._add_affiliation_email_field)
      assert affiliation_email_field.get_attribute('placeholder') == 'Email Address', \
          affiliation_email_field.get_attribute('placeholder')
      add_aff_done_btn = self._get(self._add_affiliation_done_button)
      assert add_aff_done_btn.text == 'DONE', add_aff_done_btn.text
      add_aff_cancel_link = self._get(self._add_affiliation_cancel_link)
      assert add_aff_cancel_link.text == 'cancel', add_aff_cancel_link.text

  def validate_invalid_add_new_affiliation(self):
    """
    Validate the error message for an invalid adding new affiliation.
    :return: None
    """
    self.click_add_affiliation_button()
    add_done_btn = self._get_add_done_btn()
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
    self._get(self._add_new_affiliation_btn).click()
    return self

  def validate_image_upload(self):
    """Validate uploading a new image as profile avatar"""
    # TODO: Check this when Pivotal#101632186 is fixed.
    self._get(self._profile_name_title)
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
    add_aff_title = self._get(self._add_affiliation_form_title)
    assert 'helvetica' in add_aff_title.value_of_css_property('font-family')
    assert add_aff_title.text == 'New Affiliation'
    self.validate_application_h3_style(add_aff_title)
    # Note that the sytle guide is silent on this search selector style (APERTA-6358)
    institution_input = self._get(self._add_affiliation_institution_input)
    # APERTA-6358 Commenting out until style implementation fixed.
    department_input, title_input, country, tmp, email = self._gets(self._affiliation_field)
    # APERTA-6358 Commenting out until style implementation fixed.
    # self.validate_input_field_style(department_input)
    # APERTA-6358 Commenting out until style implementation fixed.
    # self.validate_input_field_style(title_input)
    # APERTA-6358 Commenting out until style implementation fixed.
    # self.validate_single_select_dropdown_style(country)
    # Note that the sytle guide is silent on this date selector style (APERTA-6358)
    # self.validate_input_field_style(datepicker_1)
    datepicker_1, datepicker_2 = self._gets(self._datepicker)
    # Note that the sytle guide is silent on this date selector style (APERTA-6358)
    # self.validate_input_field_style(datepicker_2)
    # APERTA-6358 Commenting out until style implementation fixed.
    # self.validate_input_field_style(email)
    add_done_btn = self._get_add_done_btn()
    # APERTA-6358 Commenting out until style implementation fixed.
    # self.validate_secondary_big_green_button_style(add_done_btn)
    add_cancel_btn = self._get(self._add_affiliation_cancel_link)
    self.validate_default_link_style(add_cancel_btn)
    # Insert affiliation data
    institution_input.send_keys(affiliation['institution'])
    department_input.send_keys(affiliation['department'])
    title_input.send_keys(affiliation['title'])
    country.click()
    # Check for the country list selector before sending keys to country field
    self._get(self._add_affiliation_country_list_items)
    time.sleep(1)
    self._get(self._add_affiliation_country_input).send_keys(affiliation['country'] + Keys.RETURN)
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
    assert affiliation['start'][-4:] in affiliations[-1].text, '{0} not in {1}'.format(
        affiliation['start'], affiliations[-1].text)
    assert affiliation['end'][-4:] in affiliations[-1].text, '{0} not in {1}'.format(
        affiliation['end'], affiliations[-1].text)
    assert affiliation['email'] in affiliations[-1].text, '{0} not in {1}'.format(
        affiliation['email'], affiliations[-1].text)
    assert affiliation['country'] in affiliations[-1].text, '{0} not in {1}'.format(
        affiliation['country'], affiliations[-1].text)
    remove_icons = self._gets(self._remove_affiliation_icon)
    remove_icons[-1].click()
    alert = self._driver.switch_to_alert()
    alert.accept()
    return self
