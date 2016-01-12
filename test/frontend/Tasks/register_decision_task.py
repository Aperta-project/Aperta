#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time
import logging

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Tasks.basetask import BaseTask

__author__ = 'sbassi@plos.org'

class RegisterDecisionTask(BaseTask):
  """
  Page Object Model for Register Decision task
  """


  def __init__(self, driver, url_suffix='/'):
    super(RegisterDecisionTask, self).__init__(driver)

    #Locators - Instance members
    self._decisions = (By.CLASS_NAME, 'decision-selections')
    self._textarea = (By.TAG_NAME, 'textarea')
    self._register_btn = (By.TAG_NAME, 'button')

   #POM Actions
  def execute_decision(self, data=('Major Revision', 'Your manuscript needs major revision')):
    """
    This method completes decision card by selecting a decision and filling the
      textarea for sending an email to the author.
    :data: A two element tuple with the decision as the first element
      and the email text as the second element.
    """

    decision_d = {'Accept':0, 'Reject':1, 'Major Revision':2, 'Minor Revision':3}
    decision_labels =  self._get(self._decisions).find_elements_by_tag_name('label')
    decision_labels[decision_d[data[0]]].find_element_by_tag_name('input').click()
    # wait for the text area to load the text
    time.sleep(.5)
    self._get(self._textarea).send_keys(data[1])
    # press "Register Decision" btn
    self._get(self._register_btn).click()
    # Since there is no feedback on this action and sometimes it fails, will check
    # for checkbox that is completed after successful register.
    time.sleep(2)
    if not self._get(self._completed_cb).get_attribute('checked'):
      self._get(self._register_btn).click()
    logging.info(self._get(self._completed_cb).get_attribute('checked'))
