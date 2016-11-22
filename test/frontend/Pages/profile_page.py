#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.expected_conditions import alert_is_present

from authenticated_page import AuthenticatedPage
from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Resources import country_list

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
    self._profile_affiliation_dates = (By.CSS_SELECTOR, 'div.affiliation-existing > div + div')
    self._profile_affiliation_email = (By.CSS_SELECTOR,
                                       'div.affiliation-existing > div + div + div')
    # Affiliation Edit Mode
    self._add_affiliation_form = (By.CLASS_NAME, 'affiliations-form')
    self._add_affiliation_form_title = (By.CSS_SELECTOR, 'div.affiliations-form h3')
    self._add_affiliation_form_subtext = (By.CSS_SELECTOR, 'div.affiliations-form > p')
    self._add_affiliation_institution_error = (By.CSS_SELECTOR,
                                               'div.affiliations-form > div.error-message')
    self._add_affiliation_institution_input = (By.CSS_SELECTOR,
                                               'div.affiliations-form div div input')
    self._add_affiliation_institution_yes_dammit = (By.CSS_SELECTOR, 'div.did-you-mean-no-thanks')
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
    self._add_affiliation_email_div = (By.CSS_SELECTOR, 'div.required.email')
    self._add_affiliation_email_error = (By.CSS_SELECTOR, 'div.required.email div.error-message')
    self._add_affiliation_email_label = (By.CSS_SELECTOR, 'div.required.email > div > label')
    self._add_affiliation_email_field = (By.CSS_SELECTOR, 'div.required.email > input')

    self._add_affiliation_done_button = (By.CSS_SELECTOR, 'div.affiliations-form > button')
    self._add_affiliation_cancel_link = (By.CSS_SELECTOR, 'a.author-cancel')

    # This is present only for native, non-cas logins
    self._reset_btn = (By.CSS_SELECTOR, 'a.reset-password-link')

    self._add_new_affiliation_btn = (By.CSS_SELECTOR, 'div.user-affiliation a')
    # The following two elements *should* be conditional based on a user being a CAS user
    #   However, we are not doing the right thing: APERTA-8338
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
    self._wait_for_element(self._get(self._avatar_hover))
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
      assert 'ORCID ID:' in oid_title.text, oid_title.text
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
    # The following two elements *should* be displayed conditionally based on a user being a CAS
    #  user - but they are not. APERTA-8338
    profile_link = self._get(self._cas_profile_link)
    assert profile_link.get_attribute('target') == '_blank'
    assert profile_link.get_attribute('href') == \
        'https://community.plos.org/account/edit-profile'
    # APERTA-3085
    # self.validate_default_link_style(profile_link)
    assert 'View or edit your full profile' in profile_link.text
    profile_link_subtext = self._get(self._cas_profile_ptext)
    assert 'Any changes to your username or email will be updated ' \
           'in Aperta on your next login.' in profile_link_subtext.text, profile_link_subtext.text
    self.validate_application_ptext(profile_link_subtext)

    assert 'Affiliations:' in profile_affiliation_form_title.text
    try:
      self._get(self._profile_affiliations)
    except ElementDoesNotExistAssertionError:
      existing_affiliation = False
      logging.info('No existing affiliations found...')
      no_aff_text = self._get(self._profile_affiliation_aff_text)
      # APERTA-8178 Typo
      # assert no_aff_text.text == 'No affiliations yet', no_aff_text.text
    if not existing_affiliation:
      affiliation_btn.click()
      self._wait_for_element(self._get(self._add_affiliation_form))
      add_form_title = self._get(self._add_affiliation_form_title)
      assert add_form_title.text == 'New Affiliation', add_form_title.text
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
      self._wait_for_element(self._gets(self._add_affiliation_country_list_items)[248])
      country_input = self._get(self._add_affiliation_country_input)
      country_list_page = self._gets(self._add_affiliation_country_list_items)
      country_list_page_text = []
      for item in country_list_page:
        country_list_page_text.append(item.text)
      # Check that all items in static country list from Resources are present in page
      for item in country_list:
        assert item in country_list_page_text, u'Item: {0} in NED Country list that is not ' \
                                               u'found in the page!'.format(item)
      # Then check that there are no extra items in the Country list from page.
      for item in country_list_page_text:
        assert item in country_list, u'Extra item in country list from page: {0} - is NED ' \
                                      'Country list in Resources.py up to date?'.format(item)
      country_input.send_keys(Keys.ESCAPE)
      # A little hack to get the focus off the Country list
      profile_link_subtext.click()
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
      start_date_field.send_keys(Keys.ESCAPE)
      end_date_field.click()
      self._get(self._add_affiliation_datepicker_selector)
      end_date_field.send_keys(Keys.ESCAPE)
      email_div = self._get(self._add_affiliation_email_div)
      assert 'required' in email_div.get_attribute('class'), \
          email_div.get_attribute('class')
      affiliation_email_lbl = self._get(self._add_affiliation_email_label)
      assert affiliation_email_lbl.text == 'Email Address', affiliation_email_lbl.text
      affiliation_email_field = self._get(self._add_affiliation_email_field)
      assert affiliation_email_field.get_attribute('placeholder') == 'Email Address', \
          affiliation_email_field.get_attribute('placeholder')
      add_aff_done_btn = self._get(self._add_affiliation_done_button)
      assert add_aff_done_btn.text == 'DONE', add_aff_done_btn.text
      add_aff_cancel_link = self._get(self._add_affiliation_cancel_link)
      assert add_aff_cancel_link.text == 'cancel', add_aff_cancel_link.text
      # Most importantly, close the form when done or pain ensues...
      add_aff_cancel_link.click()
    else:
      logging.info('Existing Affiliation found...')
      self._get(self._profile_affiliation_institution)
      self._get(self._profile_affiliation_delete)
      self._get(self._profile_affiliation_edit)
      self._get(self._profile_affiliation_dept)
      self._get(self._profile_affiliation_title)
      self._get(self._profile_affiliation_country)
      date_range = self._get(self._profile_affiliation_dates)
      # APERTA-8381
      # # There is a problem that this data is mal-structured in the application so you get way more
      # # than you ask for here:
      # logging.info(date_range.text)
      # start_date, end_date = date_range.text.split(' - ')
      self._get(self._profile_affiliation_email)

  def validate_add_affiliation_validations(self, user):
    """
    Validate the adding new affiliation validations
    :param user: user object (from Resources) whose institution data will be utilized in test
    :return: None
    """
    logging.info('Validating validations')
    self.click_add_affiliation_button()
    add_done_btn = self._get(self._add_affiliation_done_button)
    add_done_btn.click()
    # Institution is NOT marked as a required field, but we insist on it - bug is no required
    #   field marker
    logging.debug('Adding in an institution to satisfy field requirement')
    institution_field = self._get(self._add_affiliation_institution_input)
    if user['affiliation-name']:
      institution_field.send_keys(user['affiliation-name'])
    else:
      institution_field.send_keys('Tramp University')
    # APERTA-8336
    # try:
    #   institution_error = self._get(self._add_affiliation_institution_error)
    #   # This error should not exist - APERTA-8336
    #   assert institution_error.text.lower() == "can't be blank", institution_error.text
    #   raise ElementExistsAssertionError()
    # except ElementDoesNotExistAssertionError:
    #   pass
    # Test for email syntax validation
    affiliation_email_field = self._get(self._add_affiliation_email_field)
    affiliation_email_field.send_keys('invalid_address')
    logging.debug('Clicking Done')
    add_done_btn.click()
    try:
      email_syntax_error = self._get(self._add_affiliation_email_error)
    except ElementDoesNotExistAssertionError:
      raise ElementDoesNotExistAssertionError('Email validation - syntax of valid address '
                                              'didn\'t fire')
    affiliation_email_field.clear()
    # Test for requirement for email field complete
    logging.debug('Clicking Done')
    add_done_btn.click()
    # APERTA-8336
    # Having not filled in email address - listed as required - should fire an error
    # try:
    #   email_error = self._get(self._add_affiliation_email_error)
    # except ElementDoesNotExistAssertionError:
    #   raise ElementDoesNotExistAssertionError('Email validation - primary existence - is not
    #   functional - field required')
    logging.info('Finished validating validations')

  def click_add_affiliation_button(self):
    """Click add addiliation button"""
    self._wait_for_element(self._get(self._add_new_affiliation_btn))
    self._get(self._add_new_affiliation_btn).click()

  def validate_image_upload(self, user):
    """
    Validate uploading a new image as profile avatar
    Note that this doesn't actually work
    :param user: user dictionary object from Base/Resources.py
    :return: void function
    """
    self._actions.move_to_element(self._get(self._avatar_div)).perform()
    avatar_input = self._iget(self._avatar_input)
    self._get(self._avatar_hover).click()
    if user['profile_image']:
      fn = os.getcwd() + '/frontend/assets/imgs/' + user['profile_image']
    else:
      fn = os.getcwd() + '/frontend/assets/imgs/plos.gif'
    avatar_input.send_keys(fn + Keys.RETURN)
    # APERTA-8337
    # TODO: Figure out how to actually trigger the upload

  def add_affiliation_cancel(self):
    """A mini method to cancel the add of a new affiliation"""
    add_aff_cancel_link = self._get(self._add_affiliation_cancel_link)
    add_aff_cancel_link.click()

  def add_affiliation(self, user):
    """
    A method to add an affilation for user
    :param user: a user dictionary from Base/Resources.py
    :return: Affiliation definition list as submitted
    """
    all_affiliations = []
    # Test for existence of "real" affiliation, if present, add a transient, else, add real
    self.set_timeout(1)
    try:
      all_affiliations = self._gets(self._profile_affiliations)
    except ElementDoesNotExistAssertionError:
      transient = False
    finally:
      self.restore_timeout()
    if all_affiliations:
      for aff in all_affiliations:
        institution = aff.find_element(*self._profile_affiliation_institution)
        if institution.text == user['affiliation-name']:
          transient = True
    self._wait_for_element(self._get(self._add_affiliation_form))
    affiliation_list = []
    institution_field = self._get(self._add_affiliation_institution_input)
    if user['affiliation-name'] and not transient:
      institution_field.send_keys(user['affiliation-name'])
      affiliation_list.append(user['affiliation-name'])
    else:
      institution_field.send_keys('Trump University')
      affiliation_list.append('Trump University')
    self.set_timeout(4)
    try:
      yesferchrissakes = self._get(self._add_affiliation_institution_yes_dammit)
      yesferchrissakes.click()
    except ElementDoesNotExistAssertionError:
      pass
    self.restore_timeout()
    department_field = self._get(self._add_affiliation_department_field)
    if user['affiliation-dept']:
      department_field.send_keys(user['affiliation-dept'])
      affiliation_list.append(user['affiliation-dept'])
    else:
      department_field.send_keys('Fraud Department')
      affiliation_list.append('Fraud Department')
    title_field = self._get(self._add_affiliation_title_field)
    if user['affiliation-title']:
      title_field.send_keys(user['affiliation-title'])
      affiliation_list.append(user['affiliation-title'])
    else:
      title_field.send_keys('Special Counselor')
      affiliation_list.append('Special Counselor')
    country_dropdown = self._get(self._add_affiliation_country_drop_list_collapsed)
    country_dropdown.click()
    self._get(self._add_affiliation_country_input)
    page_country_list = self._gets(self._add_affiliation_country_list_items)
    if user['affiliation-country']:
      for item in page_country_list:
        if item.text == user['affiliation-country']:
          item.click()
          break
      affiliation_list.append(user['affiliation-country'])
    else:
      rand_country = random.choice(country_list)
      logging.info('Selected Country for {0} is: {1}'.format(user, rand_country))
      for item in page_country_list:
        if item.text == rand_country:
          item.click()
          break
      affiliation_list.append(rand_country)
    start_date_field = self._get(self._add_affiliation_start_date_field)
    start_date_field.click()
    if user['affiliation-from']:
      start_date_field.send_keys(user['affiliation-from'])
      affiliation_list.append(user['affiliation-from'])
    else:
      start_date_field.send_keys('01/01/1970')
      affiliation_list.append('Jan, 1 1970')
    start_date_field.send_keys(Keys.ESCAPE)
    end_date_field = self._get(self._add_affiliation_end_date_field)
    if user['affiliation-to']:
      end_date_field.send_keys(user['affiliation-to'])
      affiliation_list.append(user['affiliation-to'])
    else:
      end_date_field.send_keys('11/16/2016')
      affiliation_list.append('Nov. 16 2016')
    end_date_field.send_keys(Keys.ESCAPE)
    affiliation_email_field = self._get(self._add_affiliation_email_field)
    affiliation_email_field.click()
    if user['email']:
      affiliation_email_field.send_keys(user['email'])
      affiliation_list.append(user['email'])
    else:
      affiliation_email_field.send_keys('foo@bar.com')
      affiliation_list.append('foo@bar.com')
    add_aff_done_btn = self._get(self._add_affiliation_done_button)
    add_aff_done_btn.click()
    self.check_for_flash_error()
    return affiliation_list

  def transient_affiliation_exists(self):
    """
    A method designed to identify transient affiliation entries identified by the
      "Trump University" moniker
    :return: True and the affiliation_list for the found affiliation, False and an empty list if no
      affiliation found.
    """
    aff_list = []
    self.set_timeout(3)
    try:
      all_affiliations = self._gets(self._profile_affiliations)
    except ElementDoesNotExistAssertionError:
      return False, aff_list
    finally:
      self.restore_timeout()
    for aff in all_affiliations:
      institution = aff.find_element(*self._profile_affiliation_institution)
      if institution.text == 'Trump University':
        aff_list.append(institution.text)
        department = aff.find_element(*self._profile_affiliation_dept)
        aff_list.append(department.text)
        title = aff.find_element(*self._profile_affiliation_title)
        aff_list.append(title.text)
        country = aff.find_element(*self._profile_affiliation_country)
        aff_list.append(country.text)
        date_range = aff.find_element(*self._profile_affiliation_dates)
        start_date, end_date = date_range.text.split(' - ')
        aff_list.append(start_date)
        aff_list.append(end_date)
        aff_email = aff.find_element(*self._profile_affiliation_email)
        aff_list.append(aff_email.text)
        logging.info('Transient affiliation to edit found.')
        return True, aff_list
    return False, aff_list

  def edit_affiliation(self, affiliation_to_edit_list):
    """
    Accepts a list defining the elements of an affiliation (institution, department, title, country
      start date, end date, and associated email), finds that list, then edits it, then returns the
      newly edited list
    :param affiliation_to_edit_list: a list defining the elements of an affiliation. Dates are
      expected in mm/dd/yyyy form.
    :return: a list representing the final form of the edited affiliation
    """
    logging.debug('Edit affiliation called for affiliation: {0}'.format(affiliation_to_edit_list))
    expected_inst, expected_dept, expected_title, expected_country, expected_sdate, \
        expected_edate, expected_email = affiliation_to_edit_list
    all_affiliations = self._gets(self._profile_affiliations)
    for aff in all_affiliations:
      institution = aff.find_element(*self._profile_affiliation_institution)
      department = aff.find_element(*self._profile_affiliation_dept)
      title = aff.find_element(*self._profile_affiliation_title)
      country = aff.find_element(*self._profile_affiliation_country)
      date_range = aff.find_element(*self._profile_affiliation_dates)
      # APERTA-8381
      # start_date, end_date = date_range.text.split(' - ')
      aff_email = aff.find_element(*self._profile_affiliation_email)
      if institution.text == expected_inst and department.text == expected_dept \
          and title.text == expected_title and country.text == expected_country and \
          aff_email.text == expected_email:
        logging.info('Found Affiliation, Editing...')
        edit = aff.find_element(*self._profile_affiliation_edit)
        edit.click()
        self._wait_for_element(self._get(self._add_affiliation_form))
        affiliation_list = [expected_inst, ]
        department_field = self._get(self._add_affiliation_department_field)
        department_field.clear()
        department_field.send_keys('Edited Department')
        affiliation_list.append('Edited Department')
        title_field = self._get(self._add_affiliation_title_field)
        title_field.clear()
        title_field.send_keys('Edited Title')
        affiliation_list.append('Edited Title')
        affiliation_list.append(expected_country)
        # WARNING: Due to some absolutely grisly bugs in the date fields when editing an affiliation
        #   this very specific order must be followed to avoid having the Start field spontaneously
        #   clear.
        # Also, beware that the input is really non-functional when doing date format input. If the
        #   date and month are not impossible to confuse (use a date greater than 12), the
        #   interpreter produces cracktastic results.
        # WARNING APERTA-8382
        end_date_field = self._get(self._add_affiliation_end_date_field)
        # end_date_field.click()
        end_date_field.clear()
        end_date_field.send_keys('11/16/2017')
        end_date_field.send_keys(Keys.ESCAPE)
        start_date_field = self._get(self._add_affiliation_start_date_field)
        # start_date_field.click()
        start_date_field.clear()
        start_date_field.send_keys('01/24/1980')
        affiliation_list.append('Jan 24, 1980')
        start_date_field.send_keys(Keys.ESCAPE)
        affiliation_list.append('Nov 16, 2017')
        # WARNING End special warning section
        affiliation_email_field = self._get(self._add_affiliation_email_field)
        affiliation_email_field.click()
        affiliation_email_field.clear()
        affiliation_email_field.send_keys('foobar@example.com')
        affiliation_list.append('foobar@example.com')
        add_aff_done_btn = self._get(self._add_affiliation_done_button)
        add_aff_done_btn.click()
        self.check_for_flash_error()
        return affiliation_list
      else:
        continue
    # If you hit this point, the affiliation to edit does not exist for a user which is an
    #   unintended state, so raise this as an error.
    raise(ElementDoesNotExistAssertionError, 'Affiliation: {0} '
                                             'not found'.format(affiliation_to_edit_list))

  def delete_affiliation(self, affiliation_to_delete_list):
    """
     Accepts a list defining the elements of an affiliation (institution, department, title,
     country
       start date, end date, and associated email), finds that list, then deletes it.
     :param affiliation_to_delete_list: a list defining the elements of an affiliation. Dates are
       expected in mm/dd/yyyy form.
     :return: void function
     """
    expected_inst, expected_dept, expected_title, expected_country, expected_sdate, \
        expected_edate, expected_email = affiliation_to_delete_list
    logging.debug(affiliation_to_delete_list)
    all_affiliations = self._gets(self._profile_affiliations)
    for aff in all_affiliations:
      institution = aff.find_element(*self._profile_affiliation_institution)
      department = aff.find_element(*self._profile_affiliation_dept)
      title = aff.find_element(*self._profile_affiliation_title)
      country = aff.find_element(*self._profile_affiliation_country)
      date_range = aff.find_element(*self._profile_affiliation_dates)
      # APERTA-8381
      # start_date, end_date = date_range.text.split(' - ')
      aff_email = aff.find_element(*self._profile_affiliation_email)
      if institution.text == expected_inst and department.text == expected_dept and title.text == \
          expected_title and country.text == expected_country and aff_email.text == expected_email:
        logging.info('Found Affiliation, Deleting...')
        delete = aff.find_element(*self._profile_affiliation_delete)
        delete.click()
        if alert_is_present:
          self._driver.switch_to_alert().accept()
          logging.info('Accepted Delete Alert')

  def clear_transients(self):
    """
    A housekeeping function to ensure profiles don't fill up with "transient" affiliation entries
    :return: void function
    """
    self.set_timeout(1)
    try:
      all_affiliations = self._gets(self._profile_affiliations)
    except ElementDoesNotExistAssertionError:
      return
    finally:
      self.restore_timeout()
    for aff in all_affiliations:
      institution = aff.find_element(*self._profile_affiliation_institution)
      if institution.text == 'Trump University':
        delete = aff.find_element(*self._profile_affiliation_delete)
        delete.click()
        if alert_is_present:
          self._driver.switch_to_alert().accept()
          logging.info('Accepted Delete Alert')

  def validate_affiliation(self, affiliation_definition_list):
    """
    Being passed an affiliation definition list, validates the presence of an affiliation listing
      in view mode on the user profile with the values passed.
    :param affiliation_definition_list: a seven item list representing the definition of an
      affiliation
    :return: void function
    """
    logging.debug(affiliation_definition_list)
    expected_inst, expected_dept, expected_title, expected_country, expected_sdate, \
        expected_edate, expected_email = affiliation_definition_list
    all_affiliations = self._gets(self._profile_affiliations)
    for aff in all_affiliations:
      institution = aff.find_element(*self._profile_affiliation_institution)
      department = aff.find_element(*self._profile_affiliation_dept)
      title = aff.find_element(*self._profile_affiliation_title)
      country = aff.find_element(*self._profile_affiliation_country)
      date_range = aff.find_element(*self._profile_affiliation_dates)
      # APERTA-8381
      # start_date, end_date = date_range.text.split(' - ')
      aff_email = aff.find_element(*self._profile_affiliation_email)
      if institution.text == expected_inst and department.text == expected_dept and title.text == \
          expected_title and country.text == expected_country and aff_email.text == expected_email:
        logging.info('Affiliation Validates')
        return
      logging.debug(u'{0}, {1}, {2}, {3}, {4}'.format(institution.text, department.text,
                                                      title.text, country.text, aff_email.text))
    raise(ValueError, 'The expected affiliation was not found at all...')

  def validate_no_affiliation(self, affiliation_definition_list):
    """
    Being passed an affiliation definition list, validates the affiliation listing is not present
      in view mode on the user profile with the values passed.
    :param affiliation_definition_list: a seven item list representing the definition of an
      affiliation
    :return: void function
    """
    logging.debug(affiliation_definition_list)
    expected_inst, expected_dept, expected_title, expected_country, expected_sdate, \
        expected_edate, expected_email = affiliation_definition_list
    self.set_timeout(5)
    try:
      all_affiliations = self._gets(self._profile_affiliations)
    except ElementDoesNotExistAssertionError:
      logging.info('Affiliation Validates As Deleted!')
      self.restore_timeout()
      return
    self.restore_timeout()
    for aff in all_affiliations:
      institution = aff.find_element(*self._profile_affiliation_institution)
      department = aff.find_element(*self._profile_affiliation_dept)
      title = aff.find_element(*self._profile_affiliation_title)
      country = aff.find_element(*self._profile_affiliation_country)
      date_range = aff.find_element(*self._profile_affiliation_dates)
      # APERTA-8381
      # start_date, end_date = date_range.text.split(' - ')
      aff_email = aff.find_element(*self._profile_affiliation_email)
      if institution.text == expected_inst and department.text == expected_dept and title.text == \
          expected_title and country.text == expected_country and aff_email.text == expected_email:
        logging.error('Affiliation Failed Deletion!')
        raise(ValueError, 'Affiliation: {0} failed deletion'.format(affiliation_definition_list))
    logging.info('The deleted affiliation was not found at all...A pass!')
