#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time
import random
import os
import logging

from loremipsum import generate_paragraph

from Base.Resources import docs
from frontend.Tasks.basetask import BaseTask
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys


__author__ = 'sbassi@plos.org'

class ReviseManuscriptTask(BaseTask):
  """
  Page Object Model for Revise Manuscript Task
  """
  def __init__(self, driver):
    super(ReviseManuscriptTask, self).__init__(driver)

    #Locators - Instance members
    self._subtitle = (By.CSS_SELECTOR, 'div.task-main-content h3')
    self._response_field = (By.CLASS_NAME, 'revise-overlay-response-field')
    self._save_btn = (By.CLASS_NAME, 'button-primary')
    self._btn_done = (By.CSS_SELECTOR, 'span.task-completed-section button')
    self._error_messages = (By.CLASS_NAME, 'error-message')
    self._upload_btn = (By.CLASS_NAME, 'fileinput-button')

  def validate_styles(self):
    """
    Validate styles in Revise Manuscript Card
    """
    # Without the following time, it grabs an empty string
    time.sleep(4)
    subtitle_1, subtitle_2 = self._gets(self._subtitle)
    assert subtitle_1.text.lower() == 'current revision', subtitle_1.text
    assert subtitle_2.text.lower() == 'response to reviewers:', subtitle_2.text
    response_field = self._get(self._response_field)
    assert response_field.get_attribute('placeholder') == ("Please detail the changes "
      "you've made to your submission here"), response_field.get_attribute('placeholder')
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
    msg1, msg2 = self._gets(self._error_messages)
    assert msg1.text == 'Please fix all errors', msg1.text
    assert msg2.text == 'Please provide a response or attach a file', msg2.text
    return None

  def response_to_reviewers(self, data=None):
    """
    Fill text area and/or attach files and save
    :data: Dictionary with data to complete this task.
    """
    data = data or {}
    if data and 'attach' in data and data['attach']:
      doc2upload = random.choice(docs)
      fn = os.path.join(os.getcwd(), 'frontend/assets/docs/{0}'.format(doc2upload))
      logging.info('Sending documents: {0}'.format(fn))
      time.sleep(1)
      # Testing uploading only one file due to bug APERTA-6672
      self._driver.find_element_by_tag_name('input').send_keys(fn)
      self._upload_btn = (By.CLASS_NAME, 'fileinput-button')
      self._get(self._upload_btn).click()
      # Give time to upload.
      time.sleep(10)
    if data and 'text' not in data:
      data['text'] = generate_paragraph()[2] or 'text'
    self._get(self._response_field).send_keys(data['text'])
    self._get(self._save_btn).click()
    return None
