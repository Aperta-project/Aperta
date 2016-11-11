#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.common.exceptions import WebDriverException
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.CustomException import ElementDoesNotExistAssertionError
from frontend.Pages.authenticated_page import AuthenticatedPage

__author__ = 'jgray@plos.org'


class BaseTask(AuthenticatedPage):
  """
  Common elements shared between tasks as displayed on the manuscript viewer page
  This had to be separated from the cards infrastructure as the workflow implementation
  was not changing. This should be used only for manuscript viewer situated tasks. If you
  you need to interact with a card from the workflow page, get thee to the Cards!
  """

  def __init__(self, driver):
    super(BaseTask, self).__init__(driver)

    # Common element for all tasks
    self.task_title = (By.CSS_SELECTOR, 'task-disclosure-heading')
    self._task_body = (By.CSS_SELECTOR, 'div.task-disclosure-body')
    self._completion_button = (By.CSS_SELECTOR, 'button.task-completed')
    # Error Messaging
    self._task_error_msg = (By.CSS_SELECTOR, 'span.task-completed-section div.error-message')
    # Versioning locators - only applicable to metadata cards
    self._versioned_metadata_div = (By.CLASS_NAME, 'versioned-metadata-version')
    self._versioned_metadata_version_string = (By.CLASS_NAME, 'versioned-metadata-version-string')

  # Common actions for all tasks
  def click_completion_button(self):
    """Click completed button"""
    try:
      self._get(self._completion_button).click()
    except WebDriverException:
      time.sleep(1)
      self.click_covered_element(self._get(self._completion_button))

  def completed_state(self):
    """Returns the selected state of the task completed button as a boolean"""
    self._wait_for_element(self._get(self._completion_button))
    btn_label = self._get(self._completion_button).text
    if btn_label == 'I am done with this task':
      return False
    elif btn_label == 'Make changes to this task':
      return True
    else:
      raise ValueError('Completed button in unexpected state {0}'.format(btn_label))

  def validate_completion_error(self):
    """
    Validates that we properly put up an error in the case of attempting completion of a task with
      validation errors
    :return: void function
    """
    self.set_timeout(2)
    error_msg = self._get(self._task_error_msg)
    logging.info('Validation Error was thrown Completing Task')
    assert 'Please fix all errors' in error_msg.text, error_msg.text
    self.restore_timeout()

  def validate_common_elements_styles(self):
    """Validate styles from elements common to all cards"""
    completed_btn = self._get(self._completion_button)
    assert 'I am done with this task' in completed_btn.text, completed_btn.text
    self.validate_secondary_small_green_button_task_style(completed_btn)

  def is_versioned_view(self):
    """
    Evaluate whether the card view is a versioned view
    :return: True if versioned view of card, False otherwise
    """
    if self._get(self._versioned_metadata_div):
      assert self._get(self._versioned_metadata_div).text == 'Viewing', \
          self._get(self._versioned_metadata_div).text
      return True
    else:
      return False

  def extract_current_view_version(self):
    """
    Returns the currently viewed version for a given metadata card
    :return: Version string
    """
    return self._get(self._versioned_metadata_version_string).text

  def check_flash_messages(self, expected_msg, timeout=15):
    """
    Used to check that a success message fired and that an error message did not. For the time
      being, only log a warning, do not fail the test.
    :return:
    """
    self.set_timeout(timeout)
    all_success_messages = self.get_flash_success_messages()
    success_msgs = [msg.text.split('\n')[0] for msg in all_success_messages]
    for msg in all_success_messages:
      logging.info(msg.text)
      try:
        assert expected_msg in msg.text
        found = True
      except AssertionError:
        continue
    if not found:
      raise(AssertionError, '{0} not found in success messages.'.format(expected_msg))
    # Check not error message
    try:
      error_msg = self._get(self._flash_error_msg)
      self.restore_timeout()
      # Note: Commenting out due to APERTA-7012
      # raise ElementExistsAssertionError('There is an unexpected error message')
      logging.warning('WARNING: An error message fired on saving card')
      logging.warning(error_msg.text)
    except ElementDoesNotExistAssertionError:
      pass

  def task_ready(self):
    """
    A basic method to test that a task is fully populated before we interact with it.
    :return: Void Function
    """
    self._wait_for_element(self._get(self._completion_button))
