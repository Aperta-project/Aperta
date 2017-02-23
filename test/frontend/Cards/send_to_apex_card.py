#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'scadavid@plos.org'

class SendToApexCard(BaseCard):
  """
  Page Object Model for Send to APex Card
  """

  def __init__(self, driver):
    super(SendToApexCard, self).__init__(driver)

    # Locators - Instance members
    self._apex_button = (By.CSS_SELECTOR, '.animation-fade-in > div > .send-to-apex-button')
    self._apex_message = (By.CSS_SELECTOR, 
                          '.animation-fade-in > div > div > .apex-delivery-message')

  # POM Actions
  def validate_send_to_apex_error_message(self):
    """
    Validate the Send to Apex error message
    :return: None
    """
    # Time needed for message to be ready
    time.sleep(3)
    apex_error = self._get(self._apex_message)
    assert apex_error.text == (
        "Apex Upload has failed. Paper has not been accepted"), apex_error

  def validate_send_to_apex_succeed_message(self):
    """
    Validate the Send to Apex succeed message
    :return: None
    """
    # Time needed for message to be ready
    time.sleep(3)
    apex_succeed = self._get(self._apex_message)
    assert apex_succeed.text == ("Apex Upload succeeded."), apex_succeed

  def click_send_to_apex_button(self):
    """
    Clicking Send to Apex button
    :return: None
    """
    apex_button = self._get(self._apex_button)
    apex_button.click()