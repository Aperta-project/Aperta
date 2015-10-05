#!/usr/bin/env python2

import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Cards.basecard import BaseCard
#from Base.Resources import author

__author__ = 'sbassi@plos.org'

class BillingCard(BaseCard):
  """
  Page Object Model for Billing Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(BillingCard, self).__init__(driver)

    #Locators - Instance members
    self._first_name = (By.NAME, "plos_billing.first_name")
    self._last_name = (By.NAME, "plos_billing.last_name")
    self._title = (By.NAME, "plos_billing.title")
    self._department = (By.NAME, "plos_billing.department")
    self._affiliation_div = (By.CLASS_NAME, 'did-you-mean')
    self._affiliation_change = (By.CLASS_NAME, 'did-you-mean-change')
    self._phone = (By.NAME, "plos_billing.phone_number")
    self._email = (By.NAME, "plos_billing.email_address")
    self._city = (By.NAME, "plos_billing.city")
    self._state = (By.NAME, "plos_billing.state")
    self._country = (By.CLASS_NAME, "select2-container")
    self._how_to_pay = (By.XPATH, ".//li[contains(@class, 'question')]/div/div")
    #self._pfa = ()



   #POM Actions
  def click_task_completed_checkbox(self):
    """Click task completed checkbox"""
    self._get(self._completed_check).click()
    return self

  def click_close_button_bottom(self):
    """Click close button on bottom"""
    self._get(self._bottom_close_button).click()
    return self

  def validate_styles(self):
    """Validate all styles for Authors Card"""
    ##self.get_stylegiude() # Only for development use
    self.validate_common_elements_styles()
    return self

  def add_billing_data(self, billing_data):
    """Add billing data"""
    first = self._get(self._first_name)
    first.clear()
    first.send_keys(billing_data['first'] + Keys.ENTER)
    last = self._get(self._last_name)
    last.clear()
    last.send_keys(billing_data['last'] + Keys.ENTER)
    title = self._get(self._title)
    title.clear()
    title.send_keys(billing_data['title'] + Keys.ENTER)
    department = self._get(self._department)
    department.clear()
    department.send_keys(billing_data['department'] + Keys.ENTER)
    try:
      aff = self._get(self._affiliation_div).find_element_by_tag_name('input')
    except NoSuchElementException:
      # click on
      change_link = self._get(self._affiliation_change)
      change_link.click()
      aff = self._get(self._affiliation_div).find_element_by_tag_name('input')
    aff.clear()
    aff.send_keys(billing_data['affiliation'] + Keys.ENTER)
    phone = self._get(self._phone)
    phone.clear()
    phone.send_keys(billing_data['phone'] + Keys.ENTER)
    email = self._get(self._email)
    email.clear()
    email.send_keys(billing_data['email'] + Keys.ENTER)
    city = self._get(self._city)
    city.clear()
    city.send_keys(billing_data['city'] + Keys.ENTER)
    state = self._get(self._state)
    state.clear()
    state.send_keys(billing_data['state'] + Keys.ENTER)
    country = self._get(self._country)
    country.click()
    #country.clear()
    country.send_keys(billing_data['country'] + Keys.ENTER)
    completed = self._get(self._completed_check)
    if not completed.is_selected():
      completed.click()
      time.sleep(.5)
    self._get(self._close_button).click()
