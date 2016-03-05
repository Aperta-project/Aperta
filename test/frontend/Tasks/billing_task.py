#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException
from Base.Resources import billing_data as bd

from frontend.Tasks.basetask import BaseTask

__author__ = 'sbassi@plos.org'

class BillingTask(BaseTask):
  """
  Page Object Model for Billing task
  """

  data = {}

  def __init__(self, driver, url_suffix='/'):
    super(BillingTask, self).__init__(driver)


    #Locators - Instance members
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
    self._payment_items_parent = (By.ID, 'select2-results-2')

   #POM Actions
  def complete(self, data=data):
    """
    This method completes the task Billing
    :data: A dictionary with the answers to all questions
    """

    if not data:
      data = {}
      # Complete with mockup data
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
    time.sleep(1)
    parent_div = self._get(self._payment_items_parent)
    for item in parent_div.find_elements_by_tag_name('li'):
      if item.text == 'I will pay the full fee upon article acceptance':
        item.click()
        time.sleep(1)
        break

    time.sleep(2)
    completed = self.completed_state()
    if not completed:
      self.click_completion_button()
      time.sleep(1)
    return self
