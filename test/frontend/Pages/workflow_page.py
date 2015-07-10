#!/usr/bin/env python2

from selenium.webdriver.common.by import By
from Base.PlosPage import PlosPage
import time

__author__ = 'fcabrales'

class WorkflowPage(PlosPage):
  """
  Model workflow page
  """
  def __init__(self, driver):
    super(WorkflowPage, self).__init__(driver, '/')

    #Locators - Instance members
    self._click_editor_assignment_button = (By.XPATH, './/div[2]/div[2]/div/div[4]/div')
    self._reviewer_agreement_button = (By.XPATH, "//div[@class='column-content']/div/div//div[contains(., '[A] Reviewer Agreement')]")
    self._assess_button = (By.XPATH, "//div[@class='column-content']/div/div//div[contains(., '[A] Reviewer Report')]")
    self._editorial_decision_button = (By.XPATH, "//div[@class='column-content']/div/div//div[contains(., '[A] Editorial Decision')]")
    self._click_left_nav = (By.CSS_SELECTOR, 'div.navigation-toggle')
    self._click_sign_out_link = (By.XPATH, './/div/div[1]/a')

  #POM Actions
  def click_editor_assignment_button(self):
    print ('Click editor assignment button')
    self._get(self._click_editor_assignment_button).click()
    return self

  def get_assess_button(self):
    return self._get(self._assess_button)

  def click_reviewer_agreement_button(self):
    print ('Click reviewer agreement button')
    self._get(self._reviewer_agreement_button).click()
    return self

  def click_editorial_decision_button(self):
    print ('Click editorial decision button')
    self._get(self._editorial_decision_button).click()
    return self

  def click_assess_button(self):
    print ('Click assess button')
    self._get(self._assess_button).click()
    return self

  def click_left_nav(self):
    print ('Click left navigation')
    self._get(self._click_left_nav).click()
    return self

  def click_sign_out_link(self):
    print ('Click sign out link')
    time.sleep(3)
    self._get(self._click_sign_out_link).click()
    return self
