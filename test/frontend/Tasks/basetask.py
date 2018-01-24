#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import logging
import time

from selenium.common.exceptions import WebDriverException
from selenium.webdriver.common.by import By

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
        self._versioned_metadata_version_string = (By.CLASS_NAME,
                                                   'versioned-metadata-version-string')
        self._versioned_view_redacted = (By.CSS_SELECTOR, 'span.text-diff > span.removed')
        self._versioned_view_added = (By.CSS_SELECTOR, 'span.text-diff > span.added')
        self._versioned_view_no_change = (By.CSS_SELECTOR,
                                          'span.text-diff > span:not(.removed):not(.added)')

    # Common actions for all tasks
    def click_completion_button(self):
        """Click completed button"""
        try:
            self._get(self._completion_button).click()
        except WebDriverException:
            time.sleep(1)
            self.click_covered_element(self._get(self._completion_button))

    def move2completion_button(self, task):
        """
        To scroll element to the top of manuscript and then down to the task to locate completion
            button
        :param task: webelement (task) to scroll to
        :return: void function
        """
        self._scroll_into_view(self._get(self._paper_sidebar_manuscript_id))
        self._scroll_into_view(task)

    def completed_state(self):
        """Returns the selected state of the task completed button as a boolean"""
        self._wait_for_element(self._get(self._completion_button))
        btn_label = self._get(self._completion_button).text
        if btn_label == 'I am done with this task':
            return False
        elif btn_label == 'Make changes to this task':
            return True
        else:
            raise ValueError('Completed button in unexpected state: {0}.'.format(btn_label))

    def validate_completion_error(self):
        """
        Validates that we properly put up an error in the case of attempting completion of a task
            with validation errors
        :return: void function
        """
        self.set_timeout(2)
        error_msg = self._get(self._task_error_msg)
        logging.info('Validation Error was thrown Completing Task')
        assert 'Please fix validation errors above' or 'Please fix all errors' in error_msg.text, \
            error_msg.text
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

    def check_flash_messages(self, expected_msg='', timeout=15):
        """
        Used to check that a success message fired and that an error message did not. For the time
          being, only log a warning, do not fail the test.
        :param expected_msg: A string in the flash message you expect to fire
        :param timeout: the time to wait for a flash message to fire, before moving on
        :return:
        """
        self.set_timeout(timeout)
        all_success_messages = self.get_flash_success_messages()
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
        self._wait_for_element(self._get(self._completion_button), multiplier=2.5)

    def diff_view_ready(self):
        """Ensure the diff view is ready before proceeding"""
        self._wait_for_element(self._get(self._versioned_metadata_version_string))

    def validate_diffed_text(self, old_value, new_value):
        """
        Validates the styling of diffed elements that DO NOT originate in TinyMCE fields and thus
            lack embedding in p tags.
        :param old_value: a string value for the previous version value
        :param new_value: a string value for the current version value
        :return: void function
        """
        # Note this is a bit too brittle and can run into problems if there are more than one item
        #     of diff text on a given card that "contain" you search string - In such a case the
        #     first element containing the text would be all we would evaluate.
        if old_value == new_value and new_value:
            # values exist - must look for no-diff text style
            self._new_value_element_locator = (
              By.XPATH, '//span[contains(@class, "text-diff")]'
                        '/span[not (@class) and text()="{0}"]'.format(new_value))
            new_value_element = self._get(self._new_value_element_locator)
            self.validate_diff_no_change_style(new_value_element)
        elif old_value != new_value and old_value and new_value:
            # values exist - must look for addition or redaction
            self._old_value_element_locator = (
                By.XPATH, '//span[contains(@class, \'removed\') and '
                          'text() = \'{0}\']'.format(old_value))
            self._new_value_element_locator = (
                By.XPATH, '//span[contains(@class, \'added\') and '
                          'text() = \'{0}\']'.format(new_value))
            old_value_element = self._get(self._old_value_element_locator)
            new_value_element = self._get(self._new_value_element_locator)
            logging.info('span.text-diff > span.removed:contains({0})'.format(old_value))
            logging.info(old_value_element)
            logging.info(type(old_value_element))

            self.validate_diff_redaction_style(old_value_element)
            self.validate_diff_addition_style(new_value_element)
        elif not old_value and new_value:
            # previous value didn't exist - new one does
            self._new_value_element_locator = (
              By.XPATH, '//span[contains(@class, \'added\') and '
                        'text() = \'{0}\']'.format(new_value))
            new_value_element = self._get(self._new_value_element_locator)
            self.validate_diff_addition_style(new_value_element)
        elif old_value and not new_value:
            # previous value existed - new one doesn't
            self._old_value_element_locator = (
              By.XPATH, '//span[contains(@class, \'removed\') and '
                        'text() = \'{0}\']'.format(old_value))
            old_value_element = self._get(self._old_value_element_locator)
            self.validate_diff_redaction_style(old_value_element)
        else:
            # Called with null values for old and new values
            logging.warning('Why are you wasting our time? Validate diffed text called with all '
                            'null values')

    def validate_diffed_tinymce_text(self, old_value, new_value):
        """
        Validates the styling of the diff view for values that are embedded in tinymce p tags
        :param old_value: a string value for the previous version value
        :param new_value: a string value for the current version value
        :return: void function
        """
        # Note this is a bit too brittle and can run into problems if there are more than one item
        #     of diff text on a given card that "contain" you search string - In such a case the
        #     first element containing the text would be all we would evaluate.
        if old_value == new_value and new_value:
            # values exist - must look for no-diff text style
            new_value_locator = (
                By.XPATH, '//span[contains(@class, "text-diff")]'
                          '/span[not (@class)]/p[text()="{0}"]'.format(new_value))
            new_value_element = self._get(new_value_locator)
            self.validate_diff_no_change_style(new_value_element)
        elif old_value != new_value and old_value and new_value:
            # values exist - must look for addition or redaction
            self._new_value_element_locator = (
                By.XPATH, '//span[contains(@class, \'added\')]/p[text() = '
                          '\'{0}\']'.format(new_value))
            self._new_value_element_locator = (
                By.XPATH, '//span[contains(@class, \'added\') and ./p[text() = "{0}"]]'.format(new_value))
            old_value_element = self._get(self._old_value_element_locator)
            new_value_element = self._get(self._new_value_element_locator)
            self.validate_diff_redaction_style(old_value_element)
            self.validate_diff_addition_style(new_value_element)
        elif not old_value and new_value:
            # previous value didn't exist - new one does
            self._new_value_element_locator = (
                By.XPATH, '//span[contains(@class, \'added\') and ./p[text() = "{0}"]]'.format(new_value))
            import pdb; pdb.set_trace()
            new_value_element = self._get(self._new_value_element_locator)
            self.validate_diff_addition_style(new_value_element)
        elif old_value and not new_value:
            # previous value existed - new one doesn't
            self._new_value_element_locator = (
                By.XPATH, '//span[contains(@class, \'added\')]/p[text() = '
                          '\'{0}\']'.format(new_value))
            old_value_element = self._get(self._old_value_element_locator)
            self.validate_diff_redaction_style(old_value_element)
        else:
            # Called with null values for old and new values
            logging.warning('Why are you wasting our time? Validate diffed text called with all '
                            'null values')
