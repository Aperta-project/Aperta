#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from loremipsum import generate_paragraph
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.CustomException import ElementDoesNotExistAssertionError
from frontend.Pages.authenticated_page import AuthenticatedPage, application_typeface

__author__ = 'sbassi@plos.org'

class BaseCard(AuthenticatedPage):
  """
  Common elements shared between cards. Cards are the view available from the Workflow page.
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
    self._add_comment = (By.CLASS_NAME, 'new-comment-field')
    self._following_label = (By.CLASS_NAME, 'participant-selector-label')
    #self._add_participant_btn = (By.CLASS_NAME, 'add-participant-button')
    self._completed_check = (By.CSS_SELECTOR, 'label.task-completed-section')
    self._message_comment = (By.CLASS_NAME, 'message-comment')
    self._completion_button = (By.CSS_SELECTOR, 'button.task-completed')
    self._completed_label = (By.XPATH, '//div[@class="overlay-completed-checkbox"]/div/label')
    self._bottom_close_button = (By.XPATH, '//div[@class="overlay-footer-content"]/a')
    # Versioning locators - only applicable to metadata cards
    self._versioned_metadata_div = (By.CLASS_NAME, 'versioned-metadata-version')
    self._versioned_metadata_version_string = (By.CLASS_NAME, 'versioned-metadata-version-string')

  # Common actions for all cards
  def click_completion_button(self):
    """Click completed checkbox"""
    self._get(self._completion_button).click()

  def completed_state(self):
    """Returns the selected state of the card completed button as a boolean"""
    time.sleep(.5)
    btn_label = self._get(self._completion_button).text
    if btn_label == 'I am done with this task':
      return False
    elif btn_label == 'Make changes to this task':
      return True
    else:
      raise ValueError('Completed button in unexpected state {0}'.format(btn_label))


  def click_completed_checkbox(self):
    """Click completed checkbox"""
    self._get(self._completed_check).click()

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

  @staticmethod
  def validate_plus_style(plus):
    """
    Ensure consistency in rendering the plus (+) section headings across the all cards
    # TODO: Validate with the result of #103123812
    """
    assert application_typeface in plus.value_of_css_property('font-family')
    assert plus.value_of_css_property('font-size') == '32px'
    assert plus.value_of_css_property('height') == '25px'
    assert plus.value_of_css_property('width') == '25px'
    assert plus.value_of_css_property('line-height') == '20px'
    assert plus.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert plus.value_of_css_property('background-color') == 'rgba(255, 255, 255, 1)'
    assert plus.text == '+', plus.text

  def validate_common_elements_styles(self):
    """Validate styles from elements common to all cards"""
    completed_lbl = self._get(self._completed_label)
    header_link = self._get(self._header_link)
    self.validate_accordion_task_title(header_link)
    manuscript_icon = self._get(self._manuscript_icon)
    icon_svg = manuscript_icon.find_element_by_xpath(
      "//*[local-name() = 'path']").get_attribute('d')
    assert icon_svg == ('M-171.3,403.5c-2.4,0-4.5,1.4-5.5,3.5c0,0-0.1,0-0.1,0h-9.9l-6.5-17.2  '
                        'c-0.5-1.2-1.7-2-3-1.9c-1.3,0.1-2.4,1-2.7,2.3l-4.3,'
                        '18.9l-4-43.4c-0.1-1.4-1.2-2.5-2.7-2.7c-1.4-0.1-2.7,0.7-3.2,2.1l-12.5,41.6  '
                        'h-16.2c-1.6,0-3,1.3-3,3c0,1.6,1.3,3,3,3h18.4c1.3,0,2.5-0.9,2.9-2.1l8.7-29l4.3,46.8c0.1,'
                        '1.5,1.3,2.6,2.8,2.7c0.1,0,0.1,0,0.2,0  c1.4,0,2.6-1,2.9-2.3l6.2-27.6l3.7,9.8c0.4,1.2,1.5,'
                        '1.9,2.8,1.9h11.9c0.2,0,0.3-0.1,0.5-0.1c1.1,1.7,3,2.8,5.1,2.8  c3.4,0,6.1-2.7,6.1-6.1C-165.3,'
                        '406.2-168,403.5-171.3,403.5z'), icon_svg
    # Close btn
    close_btn = self._get(self._close_button)
    self.validate_secondary_big_green_button_style(close_btn)
    discussion_div = self._get(self._discussion_div)
    discussion_title = discussion_div.find_element_by_tag_name('h2')
    assert discussion_title.text == 'Discussion', discussion_title.text
    # https://developer.plos.org/jira/browse/APERTA-2918
    # self.validate_application_h2_style(discussion_title)
    # Text area before clicking on it
    discussion_text_area = discussion_div.find_element_by_tag_name('textarea')
    assert discussion_text_area.get_attribute('placeholder') == 'Type your message here'
    # Enter into the textarea (can't use click since it is not working on CI)
    self._driver.execute_script("$('.new-comment-field').focus().focus();")
    time.sleep(1)
    discussion_div = self._iget(self._discussion_div)
    post_btn = discussion_div.find_element_by_tag_name('button')
    assert post_btn.text == 'POST MESSAGE'
    self.validate_secondary_big_green_button_style(post_btn)
    cancel_lnk = discussion_div.find_element_by_tag_name('a')
    assert cancel_lnk.text == 'Cancel', cancel_lnk.text
    self.validate_default_link_style(cancel_lnk)
    # Enter some text
    expected_text = generate_paragraph()[2]
    self.insert_text_discussion(expected_text)
    post_btn.click()
    time.sleep(1)
    # Check that the entered text is there
    message_comment = self._get(self._message_comment)
    assert expected_text in message_comment.text, (expected_text, message_comment.text)
    # Check footer
    following_label = self._get(self._following_label)
    assert following_label.text == 'Following:', following_label.text
    add_participant_btn = self._get(self._add_participant_btn)
    self.validate_plus_style(add_participant_btn)
    completed_check = self._get(self._completed_check)
    # The checkbox on the cards doesn't match the styleguide
    # https://developer.plos.org/jira/browse/APERTA-5395
    # self.validate_checkbox(completed_check)
    completed_lbl = self._get(self._completed_label)
    # the vertical align property of the checkbox label doesn't match the styleguide
    # Aperta-5396
    # self.validate_checkbox_label(completed_lbl)
    bottom_close_btn = self._get(self._bottom_close_button)
    self.validate_secondary_big_green_button_style(bottom_close_btn)

  def is_versioned_view(self):
    """
    Evaluate whether the card view is a versioned view
    :return: True if versioned view of card, False otherwise
    """
    if self.get(self._versioned_metadata_div):
      assert self.get(self._versioned_metadata_div).text == 'Viewing', self.get(self._versioned_metadata_div).text
      return True
    else:
      return False

  def extract_current_view_version(self):
    """
    Returns the currently viewed version for a given metadata card
    :return: Version string
    """
    return self.get(self._versioned_metadata_version_string).text
