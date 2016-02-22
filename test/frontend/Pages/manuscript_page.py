#!/usr/bin/env python2
# -*- coding: utf-8 -*-

__author__ = 'sbassi@plos.org'

from selenium.webdriver.common.by import By
from authenticated_page import AuthenticatedPage


class ManuscriptPage(AuthenticatedPage):
  """
  Model manuscript page
  """
  def __init__(self, driver):
    super(ManuscriptPage, self).__init__(driver, '/')

    #Locators - Instance members
    self._workflow_button = (By.XPATH, ".//a[contains(., 'Workflow')]")
    self._manuscript_id = (By.CLASS_NAME, 'task-list-doi')
    self._submit_button = (By.ID, 'sidebar-submit-paper')

  #POM Actions
  def click_workflow_button(self):
    """Click workflow button"""
    self._get(self._workflow_button).click()
    return self

  def click_submit_button(self):
    """Click submit button"""
    self._get(self._submit_button).click()

  def click_authors_card(self):
    """ """
    authors_card_title = self._get(self._authors_card)
    authors_card_title.find_element_by_xpath('.//ancestor::a').click()
    return self

