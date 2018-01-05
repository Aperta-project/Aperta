#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask

__author__ = 'jgray@plos.org'


class CompetingInterestTask(BaseTask):
  """
  Page Object Model for Early Version task
  """

  def __init__(self, driver):
    super(CompetingInterestTask, self).__init__(driver)

    # Locators - Instance members
    self._intro_text = (By.CSS_SELECTOR, '.question-text>P')
    self._card_yes_label = (By.XPATH, ("//*[@class='card-form-label'][contains(text(),'Yes')]"))
    self._card_no_label = (By.XPATH, ("//*[@class='card-form-label'][contains(text(),'No')]"))

  # POM Actions
  def validate_styles(self):
    """
    Validate styles in the Competing Interest Task
    """
    intro_text = self._get(self._intro_text)
   # self.validate_application_body_text(intro_text)
    assert intro_text.text == 'You are responsible for recognizing and disclosing on behalf of all authors ' \
                              'any competing interest that could be perceived to bias their work, ' \
                              'acknowledging all financial support and any other relevant financial ' \
                              'or non-financial competing interests.' , intro_text.text
    yes_label = self._get(self._card_yes_label)
    self.validate_checkbox_label(yes_label)
    no_label = self._get(self._card_no_label)
    self.validate_checkbox_label(no_label)

  def complete_form(self, choices):
      """
      Filling out the preprint card with selected data
      :param choices: If supplied, will fill out the form accordingly, else, will make a random
        choice. A boolean.
      """
      yes_button = self._get(self._card_yes_label)
      self._wait_for_element(yes_button)
      no_button = self._get(self._card_no_label)
      self._wait_for_element(no_button)
      if choices == 'yes':
          try:
              yes_button.click()
          except AssertionError:
              assert yes_button.is_selected

              return
      else:
          if choices == 'no':
              try:
                  no_button.click()
              except AssertionError:
                  assert no_button.is_selected

                  return
