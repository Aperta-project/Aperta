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
    self._affiliation_div = (By.CLASS_NAME, 'did-you-mean')
    self._affiliation_change = (By.CLASS_NAME, 'did-you-mean-change')
    self._how_to_pay = (By.XPATH, ".//li[contains(@class, 'question')]/div/div")
    self._publication_date = (By.CLASS_NAME, 'datepicker')
    self._provenance_div = (By.CSS_SELECTOR, 'div.provenance')

  def check_style(self, user):
    """
    Style check for the card
    :user: User to send the invitation
    """
    self.validate_common_elements_styles()
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Production Metadata'
    self.validate_application_title_style(card_title)
    #invite_text = self._get(self._invite_text)
    #assert invite_text.text == 'Academic Editor'
    #self.validate_input_field_label_style(invite_text)
    #ae_input = self._get(self._invite_box)
    #assert ae_input.get_attribute('placeholder') == 'Invite Academic Editor by name or email' ,\
    #    ae_input.get_attribute('placeholder')
    # Button
    #btn = self._get(self._compose_invite_button)
    #assert btn.text == 'COMPOSE INVITE'
    # Check disabled button
    # Style validation on disabled button is commented out due to APERTA-6768
    # self.validate_primary_big_disabled_button_style(btn)
    # Enable button to check style
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
    #import pdb; pdb.set_trace()
    provenance = self._get(self._provenance)
    #assert provenance_number.get_attribute('type') == 'number'
    self.validate_input_field_style(provenance)
    production_notes = self._get(self._production_notes)
    assert production_notes.get_attribute('placeholder') == 'Add production notes here.', \
        production_notes.get_attribute('placeholder')
    self.validate_input_field_style(production_notes)
    special_handling_instructions = self._get(self.self._special_handling_instructions)
    special_handling_instructions.get_attribute('placeholder') == \
        'Add special handling instructions here.'

    prov_div = self._get(self._provenance_div)
    prov = prov_div.find_element_by_tag_name('span')
    assert prov.text == 'provenance', prov.text
    self.validate_input_field_label_style(prov)
    kkk

    ae_input.send_keys(user['email'] + Keys.ENTER)
    ae_input.send_keys(Keys.ENTER)
    time.sleep(.5)
    self.validate_primary_big_green_button_style(btn)
    ae_input.clear()
    return None

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
