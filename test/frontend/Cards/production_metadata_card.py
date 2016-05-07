#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Cards.basecard import BaseCard
#from Base.Resources import author

__author__ = 'sbassi@plos.org'

class ProductionMedataCard(BaseCard):
  """
  Page Object Model for Production Metadata Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(ProductionMedataCard, self).__init__(driver)

    #Locators - Instance members
    self._volume_number = (By.NAME, 'production_metadata--volume_number')
    self._issue_number = (By.NAME, 'production_metadata--issue_number')
    self._provenance = (By.NAME, 'production_metadata--provenance')
    self._production_notes = (By.NAME, 'production_metadata--production_notes')
    self._special_handling_instructions = (By.NAME,
        'production_metadata--special_handling_instructions')
    self._publication_date = (By.CLASS_NAME, 'datepicker')
    self._provenance_div = (By.CSS_SELECTOR, 'div.provenance')

    self._affiliation_div = (By.CLASS_NAME, 'did-you-mean')
    self._affiliation_change = (By.CLASS_NAME, 'did-you-mean-change')
    self._how_to_pay = (By.XPATH, ".//li[contains(@class, 'question')]/div/div")
    self._volume_number_field = (By.CLASS_NAME, 'volume-number')
    self._issue_number_field = (By.CLASS_NAME, 'issue-number')


  def check_style(self, user):
    """
    Style check for the card
    :user: User to send the invitation
    """
    self.validate_common_elements_styles()
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Production Metadata'
    self.validate_application_title_style(card_title)
    publication_data = self._get(self._publication_date)
    assert publication_data.get_attribute('placeholder') == 'Select Date...'
    self.validate_input_field_style(publication_data)
    volume_number = self._get(self._volume_number)
    assert volume_number.get_attribute('type') == 'number', \
        volume_number.get_attribute('type')
    assert volume_number.get_attribute('placeholder') == 'e.g. 3', \
        volume_number.get_attribute('placeholder')
    self.validate_input_field_style(volume_number)
    issue_number = self._get(self._issue_number)
    assert issue_number.get_attribute('type') == 'number', \
        issue_number.get_attribute('type')
    assert issue_number.get_attribute('placeholder') == 'e.g. 33', \
        issue_number.get_attribute('placeholder')
    self.validate_input_field_style(issue_number)
    provenance = self._get(self._provenance)
    # Check "there is no placeholder text for Provenance"
    assert not provenance.get_attribute('placeholder')
    self.validate_input_field_style(provenance)
    production_notes = self._get(self._production_notes)
    assert production_notes.get_attribute('placeholder') == 'Add production notes here.', \
        production_notes.get_attribute('placeholder')
    self.validate_input_field_style(production_notes)
    special_handling_instructions = self._get(self._special_handling_instructions)
    special_handling_instructions.get_attribute('placeholder') == \
        'Add special handling instructions here.'
    prov_div = self._get(self._provenance_div)
    prov = prov_div.find_element_by_tag_name('span')
    assert prov.text == 'Provenance', prov.text
    self.validate_input_field_label_style(prov)
    # test submiting without required fields to check for errors
    # press I am done with this task
    done_btn = self._get(self._completion_button)
    done_btn.click()
    time.sleep(1)
    volume_field = self._get(self._volume_number_field)
    assert 'Must be a whole number' in volume_field.text
    issue_field = self._get(self._issue_number_field)
    assert 'Must be a whole number' in issue_field.text
    self.validate_error_field_style(volume_field)
    self.validate_error_msg_field_style(volume_field)
    self.validate_error_field_style(issue_field)
    self.validate_error_msg_field_style(issue_field)
    return None

  def check_function(self, user):
    """
    Style check for the card
    :user: User to send the invitation
    """
    publication_data = self._get(self._publication_date)
    assert publication_data.get_attribute('placeholder') == 'Select Date...'
    self.validate_input_field_style(publication_data)
    volume_number = self._get(self._volume_number)
    assert volume_number.get_attribute('type') == 'number', \
        volume_number.get_attribute('type')
    assert volume_number.get_attribute('placeholder') == 'e.g. 3', \
        volume_number.get_attribute('placeholder')
    self.validate_input_field_style(volume_number)
    issue_number = self._get(self._issue_number)
    assert issue_number.get_attribute('type') == 'number', \
        issue_number.get_attribute('type')
    assert issue_number.get_attribute('placeholder') == 'e.g. 33', \
        issue_number.get_attribute('placeholder')
    self.validate_input_field_style(issue_number)
    provenance = self._get(self._provenance)
    # Check "there is no placeholder text for Provenance"
    assert not provenance.get_attribute('placeholder')
    self.validate_input_field_style(provenance)
    production_notes = self._get(self._production_notes)
    assert production_notes.get_attribute('placeholder') == 'Add production notes here.', \
        production_notes.get_attribute('placeholder')
    self.validate_input_field_style(production_notes)
    special_handling_instructions = self._get(self._special_handling_instructions)
    special_handling_instructions.get_attribute('placeholder') == \
        'Add special handling instructions here.'
    prov_div = self._get(self._provenance_div)
    prov = prov_div.find_element_by_tag_name('span')
    assert prov.text == 'Provenance', prov.text


   #POM Actions
  def click_task_completed_checkbox(self):
    """Click task completed checkbox"""
    self._get(self._completed_check).click()
    return self

  def click_close_button_bottom(self):
    """Click close button on bottom"""
    self._get(self._bottom_close_button).click()
    return self

  def validate_styles(self):
    """Validate all styles for Authors Card"""
    self.validate_common_elements_styles()
    return self

  def add_billing_data(self, billing_data):
    """Add billing data"""
    completed = self._get(self._completed_check)
    if completed.is_selected():
      self._get(self._close_button).click()
      return None
    first = self._get(self._first_name)
    first.clear()
    first.send_keys(billing_data['first'] + Keys.ENTER)
    last = self._get(self._last_name)
    last.clear()
    last.send_keys(billing_data['last'] + Keys.ENTER)
    title = self._get(self._title)
    title.clear()
    title.send_keys(billing_data['title'] + Keys.ENTER)
    department = self._get(self._department)
    department.clear()
    department.send_keys(billing_data['department'] + Keys.ENTER)
    try:
      aff = self._get(self._affiliation_div).find_element_by_tag_name('input')
    except NoSuchElementException:
      # click on
      change_link = self._get(self._affiliation_change)
      change_link.click()
      aff = self._get(self._affiliation_div).find_element_by_tag_name('input')
    aff.clear()
    aff.send_keys(billing_data['affiliation'] + Keys.ENTER)
    phone = self._get(self._phone)
    phone.clear()
    phone.send_keys(billing_data['phone'] + Keys.ENTER)
    email = self._get(self._email)
    email.clear()
    email.send_keys(billing_data['email'] + Keys.ENTER)
    city = self._get(self._city)
    city.clear()
    city.send_keys(billing_data['city'] + Keys.ENTER)
    state = self._get(self._state)
    state.clear()
    state.send_keys(billing_data['state'] + Keys.ENTER)
    country = self._get(self._country)
    country.send_keys(billing_data['country'] + Keys.ENTER)
    #country.click()
    #country_input = country.find_element_by_tag_name('input')
    #country.clear()
    #import pdb; pdb.set_trace()
    #country_input.send_keys(billing_data['country'] + Keys.ENTER)

    q1 = self._get(self._question_1_dd)
    q1.click()
    q1.send_keys('PLOS Publication Fee Assistance Program (PFA)' + Keys.ENTER)
    time.sleep(.5)
    # retrieve the element again because there is a change in the status
    completed = self._get(self._completed_check)
    completed.click()
    time.sleep(.5)
    self._get(self._close_button).click()
