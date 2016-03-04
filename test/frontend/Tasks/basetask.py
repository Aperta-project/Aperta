#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from loremipsum import generate_paragraph
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from frontend.Pages.authenticated_page import AuthenticatedPage, application_typeface

__author__ = 'jgray@plos.org'

class BaseTask(AuthenticatedPage):
  """
  Common elements shared between tasks as displayed on the manuscript viewer page
  This had to be separated from the cards infrastructure as the workflow implementation
  was not changing.
  """

  def __init__(self, driver):
    super(BaseTask, self).__init__(driver)

    # Common element for all tasks
    self.task_title = (By.CSS_SELECTOR, 'task-disclosure-heading')
    self._completion_button = (By.CSS_SELECTOR, 'button.task-completed')
    # Error Messaging
    self._task_error_msg = (By.CSS_SELECTOR, 'span.task-completed-section div.error-message')
    # Versioning locators - only applicable to metadata cards
    self._versioned_metadata_div = (By.CLASS_NAME, 'versioned-metadata-version')
    self._versioned_metadata_version_string = (By.CLASS_NAME, 'versioned-metadata-version-string')

  # Common actions for all cards
  def click_completion_button(self):
    """Click completed checkbox"""
    self._get(self._completion_button).click()

  def completed_state(self):
    """Returns the selected state of the task completed button as a boolean"""
    time.sleep(.5)
    btn_label = self._get(self._completion_button).text
    if btn_label == 'I am done with this task':
      return False
    elif btn_label == 'Make changes to this task':
      return True
    else:
      raise ValueError('Completed button in unexpected state {}'.format(btn_label))

  def validate_completion_error(self):
    """
    Validates that we properly put up an error in the case of attempting completion of a task with validation errors
    :return: void function
    """
    error_msg = self._get(self._task_error_msg)
    assert 'Please fix all errors' in error_msg.text, error_msg.text

  def validate_common_elements_styles(self):
    """Validate styles from elements common to all cards"""
    completed_lbl = self._get(self._completed_label)
    assert 'I am done with this task' in completed_lbl.text, completed_lbl.text
    completed_check = self._get(self._completed_cb)
    # TODO: When styleguide catches up, assert this checkbox and label matches that guide

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
