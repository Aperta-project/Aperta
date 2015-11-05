#!/usr/bin/env python2

from selenium.webdriver.common.by import By
from authenticated_page import AuthenticatedPage


__author__ = 'sbassi@plos.org'

class ManuscriptPage(AuthenticatedPage):
  """
  Model manuscript page
  """
  def __init__(self, driver):
    super(ManuscriptPage, self).__init__(driver, '/')

    #Locators - Instance members
    self._workflow_button = (By.XPATH, ".//a[contains(., 'Workflow')]")
    self._authors_card = (By.XPATH,
      "//div[@id='paper-metadata-tasks']//div[contains(., 'Authors')]")

  #POM Actions
  def click_workflow_button(self):
    """Click workflow button"""
    self._get(self._workflow_button).click()
    return self

  def click_authors_card(self):
    """ """
    authors_card_title = self._get(self._authors_card)
    authors_card_title.find_element_by_xpath('.//ancestor::a').click()
    return self

  def click_card(self, card_name):
    """Click on a given card"""
    card_title = self._get((By.XPATH,
      "//div[@id='paper-metadata-tasks']//div[contains(., 'Authors')]"))
    card_title.find_element_by_xpath('.//ancestor::a').click()
