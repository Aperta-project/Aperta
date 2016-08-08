#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time
import logging

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError
from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'


class RegisterDecisionCard(BaseCard):
  """
  Page Object Model for Register Decision Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(RegisterDecisionCard, self).__init__(driver)

    # Locators - Instance members
    self._status_alert = (By.CSS_SELECTOR, 'div.alert-warning')
    self._decision_labels = (By.CLASS_NAME, 'decision-label')
    self._register_decision_button = (By.CLASS_NAME, 'send-email-action')

   # POM Actions
  def validate_styles(self):
    """
    Validate the elements and styles of the Register Decision card
    :return: void function
    """
    title = self._get(self._overlay_header_title)
    assert title.text == 'Register Decision', title.text
    self.validate_application_title_style(title)
    expected_labels = ('Accept', 'Reject', 'Major Revision', 'Minor Revision')
    decision_labels = self._gets(self._decision_labels)
    for label in decision_labels:
      assert label.text in decision_labels, label.text


    title_label = self._get(self._title_label)
    abstract_label = self._get(self._abstract_label)
    assert title_label.text == 'Title', title_label.text
    assert abstract_label.text == 'Abstract', abstract_label.text
    title_input = self._get(self._title_input)
    abstract_input = self._get(self._abstract_input)
    self.validate_application_h3_style(title_label)
    self.validate_application_h3_style(abstract_label)
    title_textarea = self._get(self._title_textarea)
    title_textarea.find_element(*self._textarea_bold_icon)
    title_textarea.find_element(*self._textarea_italic_icon)
    title_textarea.find_element(*self._textarea_superscript_icon)
    title_textarea.find_element(*self._textarea_subscript_icon)
    self.set_timeout(3)
    try:
      self._get(self._active_title_textarea)
    except ElementDoesNotExistAssertionError:
      pass
    finally:
      self.restore_timeout()
    title_input.click()
    time.sleep(1)
    self.set_timeout(4)
    try:
      self._get(self._active_title_textarea)
    except ElementDoesNotExistAssertionError:
      logging.warning('Programmatic isolation of this element in active form often fails due to '
                      'a kind of Heisenberg uncertainty principle that we click into the field '
                      'to set it active, but on trying to isolate the element in the DOM seems to '
                      'remove focus from the field, thus removing the --active part of the '
                      'locator. This needs to be validated manually.')
    finally:
      self.restore_timeout()
    abstract_textarea = self._get(self._abstract_textarea)
    abstract_textarea.find_element(*self._textarea_bold_icon)
    abstract_textarea.find_element(*self._textarea_italic_icon)
    abstract_textarea.find_element(*self._textarea_superscript_icon)
    abstract_textarea.find_element(*self._textarea_subscript_icon)
    self.set_timeout(4)
    try:
      self._get(self._active_abstract_textarea)
    except ElementDoesNotExistAssertionError:
      pass
    finally:
      self.restore_timeout()
    abstract_input.click()
    time.sleep(1)
    self.set_timeout(4)
    try:
      self._get(self._active_abstract_textarea)
    except ElementDoesNotExistAssertionError:
      logging.warning('Programmatic isolation of this element in active form often fails due to '
                      'a kind of Heisenberg uncertainty principle that we click into the field '
                      'to set it active, but on trying to isolate the element in the DOM seems to '
                      'remove focus from the field, thus removing the --active part of the '
                      'locator. This needs to be validated manually.')
    finally:
      self.restore_timeout()

  def register_decision(self, decision):
    """
    Register decision on publishing manuscript
    :param decision: decision to mark, accepted values:
    'Accept', 'Reject', 'Major Revision' and 'Minor Revision'
    """
    try:
      alert = self._get(self._status_alert)
      if 'A decision cannot be registered at this time. ' \
         'The manuscript is not in a submitted state.' in alert.text:
        raise ValueError('Manuscript is in unexpected state: {0}'.format(alert.text))
    except ElementDoesNotExistAssertionError:
      logging.info('Manuscript is in submitted state.')
    decision_d = {'Accept': 0, 'Reject': 1, 'Major Revision': 2, 'Minor Revision': 3}
    decision_labels = self._gets(self._decision_labels)
    decision_labels[decision_d[decision]].click()
    # Apparently there is some background work here that can put a spinner in the way
    # adding sleep to give it time
    time.sleep(3)
    # click on register decision and email the author
    self._get(self._register_decision_button).click()
    time.sleep(1)
    # give some time to allow complete to check automatically,
    self.click_close_button()
