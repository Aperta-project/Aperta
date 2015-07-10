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
    self._click_workflow_button = (By.XPATH,'.//div/ul/li[5]/a')

  #POM Actions
  def click_workflow_button(self):
    print ('Click workflow button')
    self._get(self._click_workflow_button).click()
    return self
