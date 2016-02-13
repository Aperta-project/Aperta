#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Tasks.basetask import BaseTask

__author__ = 'sbassi@plos.org'

class InitialDecisionTask(BaseTask):
  """
  Page Object Model for Initial Decision task
  """

  data = ('Invite', 'Invite for full submission')

  def __init__(self, driver, url_suffix='/'):
    super(InitialDecisionTask, self).__init__(driver)
    #Locators - Instance members
    self._decisions = (By.CLASS_NAME, 'decision-selections')
    self._textarea = (By.TAG_NAME, 'textarea')
    self._register_btn = (By.TAG_NAME, 'button')
    self._alert_info = (By.CLASS_NAME, 'alert-info')

   #POM Actions
  def execute_decision(self, data=data):
    """
    This method completes the initial decision task
    :data: A tuple with the decision and the text to include in the decision
    """
    decision_d = {'Reject':0, 'Invite':1,}
    decision_labels =  self._get(self._decisions).find_elements_by_tag_name('label')
    decision_labels[decision_d[data[0]]].click()
    time.sleep(1)
    self._get(self._textarea).send_keys(data[1])
    # press "Register Decision" btn, needs to be done twice!
    self._get(self._register_btn).click()
    self._get(self._register_btn).click()
    # Give time to register the decision
    # Check for the alert
    alert = self._get(self._alert_info).text
    if data[0] == 'Invite':
      assert 'An initial decision of \'Invite full submission\' decision has been made.' in \
        alert, alert
    else:
      assert 'An initial decision of \'Reject\' decision has been made.' in alert, alert
