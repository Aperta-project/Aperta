#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Page object definition for the billing card
"""
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'


class BillingCard(BaseCard):
  """
  Page Object Model for Billing Card
  """
  def __init__(self, driver):
    super(BillingCard, self).__init__(driver)

    # Locators - Instance members
    self._first_name = (By.NAME, "first_name")
    self._last_name = (By.NAME, "last_name")
    self._title = (By.NAME, "title")
    self._department = (By.NAME, "department")
    self._affiliation_div = (By.CLASS_NAME, 'did-you-mean')
    self._affiliation_change = (By.CLASS_NAME, 'did-you-mean-change')
    self._phone = (By.NAME, "phone_number")
    self._email = (By.NAME, "email")
    self._city = (By.NAME, "city")
    self._state = (By.NAME, "state")
    self._country = (By.CLASS_NAME, "select2-container")
    self._how_to_pay = (By.XPATH, ".//li[contains(@class, 'question')]/div/div")
    self._question_1_dd = (By.CLASS_NAME, 'payment-method')

  # POM Actions
  def click_close_button_bottom(self):
    """Click close button on bottom"""
    self._get(self._bottom_close_button).click()
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
    country.send_keys(billing_data['country'] + Keys.ENTER)
    # country.click()
    # country_input = country.find_element_by_tag_name('input')
    # country.clear()
    # import pdb; pdb.set_trace()
    # country_input.send_keys(billing_data['country'] + Keys.ENTER)

    q1 = self._get(self._question_1_dd)
    q1.click()
    q1.send_keys('PLOS Publication Fee Assistance Program (PFA)' + Keys.ENTER)
    time.sleep(.5)
    # retrieve the element again because there is a change in the status
    time.sleep(.5)
    self._get(self._close_button).click()
