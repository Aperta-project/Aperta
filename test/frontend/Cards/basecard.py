#!/usr/bin/env python2

import time

from selenium.webdriver.common.by import By
from loremipsum import generate_paragraph

from frontend.Pages.authenticated_page import AuthenticatedPage, application_typeface

__author__ = 'sbassi@plos.org'

class BaseCard(AuthenticatedPage):
  """
  Common elements shared between cards
  """

  def __init__(self, driver):
    super(BaseCard, self).__init__(driver)

    # Common element for all cards
    self._close_button = (By.CSS_SELECTOR, 'a.overlay-close-button')
    self._notepad_textarea = (By.CSS_SELECTOR, 'textarea.notepad')
    self._notepad_toggle_icon = (By.XPATH,
      "//span[contains(text(), 'Your notepad')]/preceding-sibling::i")
    self._header_link = (By.CLASS_NAME, 'overlay-header-link')
    self._manuscript_icon = (By.CLASS_NAME, 'manuscript-icon')
    self._discussion_div = (By.CLASS_NAME, 'overlay-discussion-board')

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
    """Insert text in the textarea space in the notepad element"""
    if clear:
      self._get(self._notepad_textarea).clear()
    self._get(self._notepad_textarea).send_keys(text)
    # Insert a wait time so it can be saved
    time.sleep(3)
    return self

  def insert_text_discussion(self, text, clear=True):
    """Insert text in the textarea space as comment"""
    discussion_text_area = self._get(self._discussion_div).find_element_by_tag_name('textarea')
    if clear:
      discussion_text_area.clear()
    discussion_text_area.send_keys(text)
    # Insert a wait time so it can be saved
    time.sleep(3)

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

  def validate_card_title(self,title):
    """ """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '18px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '16.2px', title.value_of_css_property('line-height')
    assert title.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'

  @staticmethod
  def validate_card_h2_style(title):
    """
    Ensure consistency in rendering page and overlay h2 section headings across the all cards
    :param title: title to validate
    # TODO: Validate with the result of #103123812
    """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '20px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '22px'
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  def validate_common_elements_styles(self):
    """Validate styles from elements common to all cards"""
    header_link = self._get(self._header_link)
    self.validate_card_title(header_link)
    manuscript_icon = self._get(self._manuscript_icon)
    icon_svg = manuscript_icon.find_element_by_xpath(
      "//*[local-name() = 'path']").get_attribute('d')
    assert icon_svg == ('M4,10h24c1.104,0,2-0.896,2-2s-0.896-2-2-2H4C2.896,6,2,6.896,2,8S2.896,'
      '10,4,10z M28,14H4c-1.104,0-2,0.896-2,2  s0.896,2,2,2h24c1.104,0,2-0.896,2-2S29.104,14,28'
      ',14z M28,22H4c-1.104,0-2,0.896-2,2s0.896,2,2,2h24c1.104,0,2-0.896,2-2  S29.104,22,28,22z')
    # Close btn
    close_btn = self._get(self._close_button)
    self.validate_secondary_green_button_style(close_btn)
    #h2
    discussion_div = self._get(self._discussion_div)
    discussion_title = discussion_div.find_element_by_tag_name('h2')
    assert discussion_title.text == 'Discussion', discussion_title.text
    self.validate_card_h2_style(discussion_title)
    # Text area before clicking on it
    discussion_text_area = discussion_div.find_element_by_tag_name('textarea')
    assert discussion_text_area.get_attribute('placeholder') == 'Type your message here'
    # Text area after clicking on it
    discussion_text_area.click()
    time.sleep(1)
    discussion_div = self._get(self._discussion_div)
    post_btn = discussion_div.find_element_by_tag_name('button')
    assert post_btn.text == 'POST MESSAGE', post_btn.text
    self.validate_secondary_green_button_style(post_btn)
    cancel_lnk = discussion_div.find_element_by_tag_name('a')
    assert cancel_lnk.text == 'Cancel', cancel_lnk.text
    self.validate_default_link_style(cancel_lnk)
    # Enter some text
    expected_text = generate_paragraph()[2]
    self.insert_text_discussion(expected_text)
    post_btn.click()
    time.sleep(1)
