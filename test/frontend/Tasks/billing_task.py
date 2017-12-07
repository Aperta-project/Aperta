#!/usr/bin/env python3
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
    self._affiliation1 = (By.CSS_SELECTOR, 'div.plos_billing--affiliation1 input')
    self._phone = (By.NAME, 'plos_billing--phone_number')
    self._email = (By.NAME, 'plos_billing--email')
    self._department = (By.NAME, 'plos_billing--department')
    self._address1 = (By.NAME, 'plos_billing--address1')
    self._city = (By.NAME, 'plos_billing--city')
    self._zip = (By.NAME, 'plos_billing--postal_code')
    self._payment_option = (By.CSS_SELECTOR, 'div.payment-method a')
    self._affiliation1_parent = (By.CLASS_NAME, 'plos_billing--affiliation1')
    # This ID is bogus and dynamic, untrustworthy
    self._payment_prices_ul = (By.CSS_SELECTOR, 'div.task-main-content > div > p + ul')
    self._payment_items_parent = (By.CSS_SELECTOR, 'div.select2-drop-active')
    self._payment_option_arrow = (By.CSS_SELECTOR, 'div.affiliation-field span.select2-arrow')

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
      data['last_name'] = bd['last']
      data['department'] = bd['department']
      data['affiliation'] = bd['affiliation']
      data['phone'] = bd['phone']
      data['email'] = bd['email']
      data['address1'] = bd['address1']
      data['city'] = bd['city']
      data['zip'] = bd['ZIP']

    self._wait_for_element(self._get(self._first_name))
    self._get(self._first_name).send_keys(data['fist_name'])
    self._get(self._last_name).send_keys(data['last_name'])
    self._get(self._department).send_keys(data['department'])
    affiliation1 = self._get(self._affiliation1)
    affiliation1_parent = self._get(self._affiliation1_parent)
    self.scroll_element_into_view_below_toolbar(self._get(self._department))
    affiliation1.send_keys(data['affiliation'])
    self.select_institution(affiliation1_parent, data['affiliation'])
    self._get(self._phone).send_keys(data['phone'])
    self._get(self._email).send_keys(data['email'])
    self._get(self._address1).send_keys(data['address1'])
    self._get(self._city).send_keys(data['city'])
    self._get(self._zip).send_keys(data['zip'])
    self._wait_for_text_to_be_present_in_element_value(self._zip, data['zip'])
    payment_prices = self._get(self._payment_prices_ul)
    self._scroll_into_view(payment_prices)
    self._wait_for_element(self._get(self._payment_option))
    payment_select = self._get(self._payment_option)
    payment_options_arrow = self._get(self._payment_option_arrow)
    payment_options_arrow.click()
    # Grab the items in the select2 dropdown, then make selection
    # previous send_keys method no longer works.
    self._wait_for_element(self._get(self._payment_items_parent))
    payment_option_default = 'I will pay the full fee upon article acceptance'
    parent_div = self._get(self._payment_items_parent)
    for item in parent_div.find_elements_by_class_name('select2-result-label'):
      if item.text == payment_option_default:
        logging.info('Selecting Payment Option: {0}'.format(payment_option_default))
        item.click()
        break
    completed = self.completed_state()
    if not completed:
      # Scroll to top to leave the complete button without obstructions
      manuscript_id_text = self._get(self._paper_sidebar_manuscript_id)
      self._scroll_into_view(manuscript_id_text)
      self._wait_for_element(self._get(self._completion_button))
      self.click_completion_button()
      time.sleep(1)
    return self
