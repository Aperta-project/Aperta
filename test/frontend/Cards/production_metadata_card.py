#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import random
import time
import uuid

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from frontend.Cards.basecard import BaseCard

from datetime import datetime

__author__ = 'sbassi@plos.org'

class ProductionMedataCard(BaseCard):
  """
  Page Object Model for Production Metadata Card
  """
  def __init__(self, driver):
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

  def check_style(self):
    """
    Style check for the card
    :return: None
    """
    self.validate_common_elements_styles()
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Production Metadata'
    self.validate_application_title_style(card_title)
    publication_date = self._get(self._publication_date)
    assert publication_date.get_attribute('placeholder') == 'Select Date...', \
      publication_date.get_attribute('placeholder')
    self.validate_input_field_style(publication_date)
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
    # Style validation commented out due to bug APERTA-6901
    #self.validate_error_field_style(volume_field)
    #self.validate_error_msg_field_style(volume_field)
    #self.validate_error_field_style(issue_field)
    #self.validate_error_msg_field_style(issue_field)
    return None

  def complete_card(self, data=None):
    """
    Complete the Production Metadata card using custom or random data
    :data: Dictionary with data to complete the card. If empty,
      will generate random data.
    :return: data used to complete the card
    """
    # Input data, close, open and check if it is saved 05/04/2016
    if not data:
      date = time.strftime('%m/%d/%Y')
      volume = str(random.randint(1,10))
      issue = str(random.randint(1,10))
      provenance = str(uuid.uuid4())
      production_notes = str(uuid.uuid4())
      special_handling_instructions = str(uuid.uuid4())
      data = {'date': date,
              'volume': volume,
              'issue': issue,
              'provenance': provenance,
              'production_notes': production_notes,
              'special_handling_instructions': special_handling_instructions,
              }
    publication_date = self._get(self._publication_date)
    volume_number = self._get(self._volume_number)
    issue_number = self._get(self._issue_number)
    provenance = self._get(self._provenance)
    production_notes = self._get(self._production_notes)
    special_handling_instructions = self._get(self._special_handling_instructions)
    publication_date.send_keys(data['date'])
    volume_number.send_keys(data['volume'])
    issue_number.send_keys(data['issue'])
    provenance.send_keys(data['provenance'])
    production_notes.send_keys(data['production_notes'])
    special_handling_instructions.send_keys(data['special_handling_instructions'])
    ts = time.time()
    timestamp = datetime.fromtimestamp(ts).strftime('%Y%m%d-%H%M%S')
    self._driver.save_screenshot('Output/PMD_before_closing_card-{}.png'.format(timestamp))
    self.click_completion_button()
    # Time to save
    time.sleep(2)    
    return data

   #POM Actions
  def validate_styles(self):
    """Validate all styles for Production Metadata Card"""
    self.validate_common_elements_styles()
    return self
