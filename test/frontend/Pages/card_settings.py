#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Page Object Model for the Card Settings Page on Workflow Tab. Validates elements and their styles,
and functions.
also includes
Page Object Model for the card settings overlay.
"""
import logging

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'gtimonina@plos.org'


class CardSettings(BaseCard):
  """
  Model the Card Settings Page on Workflow Tab elements and their functions
  """
  def __init__(self, driver):
    super(CardSettings, self).__init__(driver)
    # locators for card settings overlay
    self._save_button = (By.CSS_SELECTOR, 'div.overlay-action-buttons>button.button-primary')
    self._cancel_link = (By.CSS_SELECTOR, 'button.cancel')

  def validate_card_setting_style(self, title):
    """
    Validate style and components of Card Settings overlay:
    title, cancel and save button
    """
    expected_overlay_title = title #'Similarity Check: Settings'
    overlay_title = self._get(self._overlay_header_title)
    assert overlay_title.text == expected_overlay_title, 'The card title: {0} is not the expected: ' \
                                                         '{1}'.format(overlay_title.text, expected_overlay_title)
    #
    self.validate_overlay_card_title_style(overlay_title)

    cancel_link = self._get(self._cancel_link)
    self. validate_admin_link_style(cancel_link)

    save_overlay_button = self._get(self._save_button)
    assert save_overlay_button.text == 'SAVE'
    self.validate_primary_big_blue_button_style(save_overlay_button)

  def click_save_settings(self):
    """
    function to save settings: click on 'SAVE' button on settings overlay
    :return: void function
    """
    #self._wait_for_element(self._get(self._save_button))
    save_overlay_button = self._get(self._save_button)
    save_overlay_button.click()

  def click_cancel(self):
    """
    function to save settings: click on 'cancel' link on settings overlay
    :return: void function
    """
    #self._wait_for_element(self._get(self._cancel_link))
    cancel_overlay_button = self._get(self._cancel_link)
    cancel_overlay_button.click()

  def overlay_ready(self):
    """"Ensure the overlay is ready to test"""
    self._wait_for_element(self._get(self._save_button), .5)
