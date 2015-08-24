#!/usr/bin/env python2

from selenium.webdriver.common.by import By
from Base.PlosPage import PlosPage

__author__ = 'fcabrales'

class ManuscriptPage(PlosPage):
  """
  Model manuscript page
  """
  def __init__(self, driver):
    super(ManuscriptPage, self).__init__(driver, '/')

    #Locators - Instance members
    self._workflow_button = (By.XPATH,".//a[contains(., 'Workflow')]")

  #POM Actions
  def click_workflow_button(self):
    """Click workflow button"""
    self._get(self._workflow_button).click()
    return self
