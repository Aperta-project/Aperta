#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Page object definition for the preprint posting card
"""
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.support.expected_conditions import element_to_be_clickable, visibility_of

from frontend.Cards.basecard import BaseCard

__author__ = 'gholmes@plos.org'


class PrePrintPostCard(BaseCard):
  """
  Page Object Model for Billing Card
  """
  def __init__(self, driver):
    super(PrePrintPostCard, self).__init__(driver)

    # Locators - Instance members
    self._intro_text = (By.CSS_SELECTOR, 'div[id^="ember"] li div > p')
    self._benefit_text = (By.CSS_SELECTOR, 'div[id^="ember"] ol')

    self._yes_radio_button = (By.XPATH,"//input[@class='ember-view'][@value='1']")
    self._no_radio_button = (By.XPATH, "//input[@class='ember-view'][@value='2']")
    self._card_opt_in_content_label = (By.CSS_SELECTOR, 'div>label:nth-child(1)')
    self._card_opt_out_content_label = (By.CSS_SELECTOR, 'div>label:nth-child(2)')
    self._yes_disabled_radio_button = (By.XPATH,"//input[@class='ember-view'][@value='1'][@disabled='']")
    self._no_disabled_radio_button = (By.XPATH,"//input[@class='ember-view'][@value='1'][@disabled='']")



  def validate_styles(self):
    """
    Validate styles for the Preprint Posting Card
    """
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Preprint Posting', card_title.text
    self.validate_overlay_card_title_style(card_title)
    intro_text = self._get(self._intro_text)
    self.validate_application_body_text(intro_text)
    benefits_text = self._get(self._benefit_text)
    self.validate_application_body_text(benefits_text)
    assert intro_text.text == "Benefit: Establish priority", intro_text.text
    assert "Benefit: Gather feedback" in benefits_text.text,benefits_text.text
    assert "Benefit: Cite for funding" in benefits_text.text,benefits_text.text
    opt_in_checkbox = self._get(self._yes_radio_button)
    assert opt_in_checkbox.is_selected(), 'Default value for Preprint Posting Card should be selected, it isn\'t'
    assert self._get(self._card_opt_in_content_label).text == "Yes, I want to accelerate research by publishing a preprint ahead of peer review"
    assert self._get(self._card_opt_out_content_label).text == "No, I do not want my article to appear online ahead of the reviewed article"
    self.validate_radio_button_label(self._get(self._card_opt_in_content_label))
    self.validate_radio_button_label(self._get(self._card_opt_out_content_label))


  def is_yes_button_checked(self):
    """
    Checks if yes radio button for publishing a preprint is selected
    :return: Bool
    """
    button_check = self._get(self._yes_radio_button)
    if button_check.is_selected():
      return True
    else:
      return False

  def check_opt_out_button(self):
    """
    Click on the checkmark for the question:
    "Yes - I confirm our figures comply with the guidelines."
    :return: None
    """
    self._get(self._no_radio_button).click()
    time.sleep(2)
    button_opt_out_check = self._get(self._no_radio_button)
    assert button_opt_out_check.is_selected()

  def elementstate(self):

    """
      Asserting elements should not be clickable for external users
       """
    button_opt_out_disabled_check = self._get(self._no_disabled_radio_button)
    button_opt_in_disabled_check = self._get(self._yes_disabled_radio_button)
    if button_opt_in_disabled_check.is_displayed:
      return True
    else:
      return False
    if button_opt_out_disabled_check.is_displayed:
      return True
    else:
      return False




