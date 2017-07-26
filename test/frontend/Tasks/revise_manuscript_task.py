#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time
import random
import os
import logging

from Base.Resources import docs
from frontend.Tasks.basetask import BaseTask
from selenium.webdriver.common.by import By

__author__ = 'sbassi@plos.org'


class ReviseManuscriptTask(BaseTask):
  """
  Page Object Model for Revise Manuscript Task
  """
  def __init__(self, driver):
    super(ReviseManuscriptTask, self).__init__(driver)

    # Locators - Instance members
    self._subtitle = (By.CSS_SELECTOR, 'div.task-main-content h3')
    self._decision_letter_anchor_link = (By.CSS_SELECTOR, 'div.row > div > a.link_ref')
    self._response_field_help_text = (By.CSS_SELECTOR, 'div.response-to-reviewers > p')
    self._response_field = (By.CLASS_NAME, 'revise-overlay-response-field')
    self._save_btn = (By.CLASS_NAME, 'button-primary')
    self._btn_done = (By.CSS_SELECTOR, 'span.task-completed-section button')
    self._error_messages = (By.CLASS_NAME, 'error-message')
    self._upload_btn = (By.CLASS_NAME, 'fileinput-button')
    self._response_texts = (By.CSS_SELECTOR, 'div.response-to-reviewers > p')

  def validate_styles(self):
    """
    Validate styles in Revise Manuscript Card
    """
    # Without the following time, it grabs an empty string
    time.sleep(4)
    subtitle_1, subtitle_2, subtitle_3 = self._gets(self._subtitle)
    assert subtitle_1.text == 'Response to reviewers', subtitle_1.text
    assert subtitle_2.text == 'Decision Letter', subtitle_2.text
    assert subtitle_3.text == 'Decision History', subtitle_3.text
    # APERTA-10618
    # decision_anchor_link = self._get(self._decision_letter_anchor_link)
    # assert decision_anchor_link.text == 'See Decision Letter below', decision_anchor_link.text
    response_field_hint = self._get(self._response_field_help_text)
    # APERTA-10618
    # expected_field_hint_text = 'Please upload an additional version of your manuscript that ' \
    #                           'highlights the changes you\'ve made. You may also upload your ' \
    #                           'point by point \'response to reviewers\' file here.'
    # assert response_field_hint.text == expected_field_hint_text, response_field_hint.text

    save_btn = self._get(self._save_btn)
    assert save_btn.text == "SAVE", \
      '{0} is different from {1}'.format(save_btn.text, "SAVE")
    self.validate_primary_big_green_button_style(save_btn)
    return None

  def validate_empty_response(self):
    """
    Click on Done button without filling the text area
    """
    # press I am done with this task
    self._get(self._btn_done).click()
    # wait for error
    time.sleep(2)
    messages = self._gets(self._error_messages)
    assert messages[0].text == 'Please fix all errors', messages[0].text
    assert messages[1].text == 'Please provide a response or attach a file', messages[1].text
    return None

  def response_to_reviewers(self, data=None):
    """
    Fill text area and/or attach files and save
    :data: Dictionary with data to complete this task.
    """
    data = data or {}
    if data and 'attach' in data and data['attach']:
      doc2upload = random.choice(docs)
      fn = os.path.join(os.getcwd(), doc2upload)
      logging.info('Sending documents: {0}'.format(fn))
      time.sleep(1)
      # Testing uploading only one file due to bug APERTA-6672
      self._driver.find_element_by_css_selector('input.add-new-attachment').send_keys(fn)
    elif data and 'text' in data:
      tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
        self.get_rich_text_editor_instance('revise-overlay-response-field')
      self.tmce_clear_rich_text(tinymce_editor_instance_iframe)
      self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=data['text'])


    self._get(self._save_btn).click()
    return None
