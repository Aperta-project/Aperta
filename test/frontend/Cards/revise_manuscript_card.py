#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class ReviseManuscriptCard(BaseCard):
  """
  Page Object Model for Register Decision Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(ReviseManuscriptCard, self).__init__(driver)

    #Locators - Instance members
    self._card_title = (By.TAG_NAME, 'h1')
    self._intro_text = (By.TAG_NAME, 'p')
    self._subtitle = (By.TAG_NAME, 'h3')
    self._response_field = (By.CLASS_NAME, 'revise-overlay-response-field')
    self._save_btn = (By.CLASS_NAME, 'button-primary')


  def validate_styles(self):
    """
    Validate styles in Revise Manuscript Card
    """

    card_title = self._get(self._card_title)
    assert card_title.text == 'Revise Manuscript'
    subtitle_1, subtitle_2 = self._gets(self._subtitle)
    assert subtitle_1.text == 'Current Revision'
    assert subtitle_2.text == 'Revision Details:'
    self.validate_application_title_style(card_title)
    intro_text = self._get(self._intro_text)
    self.validate_application_ptext(intro_text)
    response_field = self._get(self._response_field)
    assert response_field.get_attribute('placeholder') == ("Please detail the changes "
      "you've made to your submission here")
    save_btn = self._get(self._save_btn)
    save_btn.text == "SAVE"
    self.validate_primary_big_green_button_style(save_btn)
    return self
