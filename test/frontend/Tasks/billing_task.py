#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Resources import billing_data as bd
from frontend.Tasks.basetask import BaseTask

__author__ = 'sbassi@plos.org'


class BillingTask(BaseTask):
  """
  Page Object Model for Billing task
  """
  data = {}
  def __init__(self, driver):
    super(BillingTask, self).__init__(driver)

    # Locators - Instance members
    self._first_name = (By.NAME, 'plos_billing--first_name')
    self._last_name = (By.NAME, 'plos_billing--last_name')
    self._department = (By.NAME, 'plos_billing--department')
    self._phone = (By.NAME, 'plos_billing--phone_number')
    self._email = (By.NAME, 'plos_billing--email')
    self._department = (By.NAME, 'plos_billing--department')
    self._address1 = (By.NAME, 'plos_billing--address1')
    self._city = (By.NAME, 'plos_billing--city')
    self._zip = (By.NAME, 'plos_billing--postal_code')
    self._payment_option = (By.CLASS_NAME, 'affiliation-field')
    # This ID is bogus and dynamic, untrustworthy
    self._payment_items_parent = (By.ID, 'select2-results-2')

   # POM Actions
  def complete(self, data=data):
    """
    This method completes the task Billing
    :param data: A dictionary with the answers to all questions
    """
    if not data:
      data = {}
      # Complete with mock-up data
      data['fist_name'] = bd['first']
      data['last_name'] = bd['first']
      data['department'] = bd['department']
      data['phone'] = bd['phone']
      data['email'] = bd['email']
      data['address1'] = bd['address1']
      data['city'] = bd['city']
      data['zip'] = bd['ZIP']

    self._get(self._first_name).send_keys(data['fist_name'])
    self._get(self._last_name).send_keys(data['last_name'])
    self._get(self._department).send_keys(data['department'])
    self._get(self._phone).send_keys(data['phone'])
    self._get(self._email).send_keys(data['email'])
    self._get(self._address1).send_keys(data['address1'])
    self._get(self._city).send_keys(data['city'])
    self._get(self._zip).send_keys(data['zip'])
    payment_select = self._get(self._payment_option)
    payment_select.click()
    # Grab the items in the select2 dropdown, then make selection
    # previous send_keys method no longer works.
    payment_option_default = 'I will pay the full fee upon article acceptance'
    time.sleep(2)
    # This locator is dynamic and unpredictable
    self.set_timeout(2)
    try:
      parent_div = self._get(self._payment_items_parent)
    except ElementDoesNotExistAssertionError:
      self._payment_items_parent = (By.ID, 'select2-results-4')
      parent_div = self._get(self._payment_items_parent)
    self.restore_timeout()
    # for item in parent_div.find_elements_by_tag_name('li'):
    for item in parent_div.find_elements_by_class_name('select2-result-label'):
      if item.text == payment_option_default:
        logging.info('Selecting Payment Option: {0}'.format(payment_option_default))
        item.click()
        time.sleep(1)
        break
    time.sleep(2)
    completed = self.completed_state()
    if not completed:
      self.click_completion_button()
      time.sleep(1)
    return self
