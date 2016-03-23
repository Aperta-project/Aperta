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
      logging.info('Manuscript is in expected state.')
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
