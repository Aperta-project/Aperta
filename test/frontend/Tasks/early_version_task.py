#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask

__author__ = 'jgray@plos.org'


class EarlyVersionTask(BaseTask):
  """
  Page Object Model for Early Version task
  """

  def __init__(self, driver):
    super(EarlyVersionTask, self).__init__(driver)

    # Locators - Instance members
    self._intro_text = (By.CSS_SELECTOR, 'div.card-content.card-content-view-text.ember-view > p')
    self._accman_consent_checkbox = (By.ID, 'check-box-early-posting--consent')
    self._accman_consent_label = (By.CSS_SELECTOR, '#check-box-early-posting--consent + span')

  # POM Actions
  def validate_styles(self):
    """
    Validate styles in the Early Version Task
    """
    intro_text = self._get(self._intro_text)
    self.validate_application_body_text(intro_text)
    assert intro_text.text == 'A copy of your uncorrected proof will be published online ahead ' \
                              'of the final version of your manuscript, should your manuscript ' \
                              'be accepted. If you do NOT consent to having an early version of ' \
                              'your paper published online, please uncheck the box below. Please ' \
                              'note, if you change your mind, you may choose to opt out up until ' \
                              'final acceptance.', intro_text.text
    opt_in_checkbox = self._get(self._accman_consent_checkbox)
    # APERTA-8500
    # self.validate_checkbox(opt_in_checkbox)
    assert opt_in_checkbox.is_selected(), 'Default value for EV should be selected, it isn\'t'
    opt_in_label = self._get(self._accman_consent_label)
    self.validate_checkbox_label(opt_in_label)

  def complete_form(self, choice=''):
    """
    Fill out the single item EV form with supplied data or random data if none provided
    :param choice: If supplied, will fill out the form accordingly, else, will make a random
      choice. A boolean.
    :returns choice: the selection to opt in or opt out, a boolean. (True=Opt in; False=Opt out)
    """
    choices = [True, False]
    already_deselected = False
    opt_in_checkbox = self._get(self._accman_consent_checkbox)
    if choice:
      assert choice in choices, 'Selected can only be True or False. Supplied: ' \
                                      '{0}'.format(choice)
    else:
      choice = random.choice(choices)
    logging.info('Early Version selection is: {0}'.format(choice))
    if choice:
      try:
        assert opt_in_checkbox.is_selected()
      except AssertionError:
        opt_in_checkbox.click()
    else:
      try:
        assert opt_in_checkbox.is_selected()
      except AssertionError:
        already_deselected = True
      if not already_deselected:
        opt_in_checkbox.click()
      # Abe is, I believe saying this click is not registered before we move on. So adding a dread
      #   sleep.
      time.sleep(.5)
    return choice
