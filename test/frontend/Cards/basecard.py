#!/usr/bin/env python2

import time

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.PlosPage import PlosPage


__author__ = 'sbassi@plos.org'

class BaseCard(PlosPage):
  """
  Common elements shared between cards
  """
  
  def __init__(self, driver):
    super(BaseCard, self).__init__(driver)

    # Common element for all cards
    self._close_button = (By.CSS_SELECTOR, 'a.overlay-close-button')
    self._notepad_textarea = (By.CSS_SELECTOR, 'textarea.notepad')
    self._notepad_toggle_icon = (By.XPATH, "//span[contains(text(), 'Your notepad')]/preceding-sibling::i")

  # Common actions for all cards
  def click_close_button(self):
    """Click close button"""
    self._get(self._close_button).click()
    return self

  def notepad_present(self):
    """Check if notepad element is present"""
    try:
      self._get(self._notepad_textarea)
      return True
    except ElementDoesNotExistAssertionError:
      return False

  def get_text_notepad(self):
    """Get text in the textarea space in the notepad element"""
    # Give some time for text to load
    time.sleep(2)
    return self._get(self._notepad_textarea).get_attribute('value')

  def insert_text_notepad(self, text, clear=True):
    """
    Insert text in the textarea space in the notepad element
    """
    if clear:
      self._get(self._notepad_textarea).clear()
    self._get(self._notepad_textarea).send_keys(text)
    # Insert a wait time so it can be saved
    time.sleep(3)
    return self

  def is_notepad_icon_open(self):
    """Check if notepad icon is in open position"""
    glyph_type = self._get(self._notepad_toggle_icon).get_attribute('class').split(" ")[1]
    if glyph_type == 'glyphicon-triangle-bottom':
      return True
    else:
      return False

  def toggle_notepad_icon(self):
    """Click on the notepad open/close icon"""
    self._get(self._notepad_toggle_icon).click()
    return self