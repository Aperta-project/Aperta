#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import random
import time

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'jgray@plos.org'

class InitialDecisionCard(BaseCard):
  """
  Page Object Model for the Initial Decision Card
  """
  def __init__(self, driver):
    super(InitialDecisionCard, self).__init__(driver)

    #Locators - Instance members
    self._card_title = (By.TAG_NAME, 'h1')
    self._intro_text = (By.TAG_NAME, 'p')
    self._reject_radio_button = (By.XPATH, '//input[@value=\'reject\']')
    self._invite_radio_button = (By.XPATH, '//input[@value=\'invite_full_submission\']')
    self._decision_letter_textarea = (By.TAG_NAME, 'textarea')
    self._register_decision_btn = (By.XPATH, '//textarea/following-sibling::button')
    #TD: Find out why classn_name and tag_name locator not working here
    #self._register_decision_btn = (By.CLASS_NAME, 'button-primary')
    self._alert_info = (By.CLASS_NAME, 'alert-info')

   #POM Actions

  def validate_styles(self):
    """
    Validate styles for the Initial Decision Card
    """
    card_title = self._get(self._card_title)
    assert card_title.text == 'Initial Decision'
    # Commented out until bug APERTA-3090 is fixed
    #self.validate_application_h1_style(card_title)
    intro_text = self._get(self._intro_text)
    self.validate_application_ptext(intro_text)
    assert intro_text.text == 'Please write your decision letter in the area below', intro_text.text
    self._get(self._reject_radio_button)
    self._get(self._invite_radio_button)
    self._get(self._decision_letter_textarea)
    reg_dcn_btn = self._get(self._register_decision_btn)
    # this button is disabled by default now
    #TD: Disabled for testing until having answer from Design
    ##self.validate_secondary_big_disabled_button_style(reg_dcn_btn)

  def execute_decision(self, choice='random'):
    """
    Randomly renders an initial decision of reject or invite, populates the decision letter
    :return: selected choice
    """
    choices = ['reject', 'invite']
    decision_letter_input = self._get(self._decision_letter_textarea)
    if choice == 'random':
      choice = random.choice(choices)
    if choice == 'reject':
      reject_input = self._get(self._reject_radio_button)
      reject_input.click()
      time.sleep(.5)
      decision_letter_input.send_keys('Rejected')
    else:
      invite_input = self._get(self._invite_radio_button)
      invite_input.click()
      time.sleep(.5)
      decision_letter_input.send_keys('Invited')
    # Time to allow the button to change to clickleable state
    time.sleep(.5)
    self._get(self._register_decision_btn).click()
    return choice
