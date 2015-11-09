#!/usr/bin/env python2

import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Cards.basecard import BaseCard
#from Base.Resources import author

__author__ = 'sbassi@plos.org'

class RegisterDecisionCard(BaseCard):
  """
  Page Object Model for Register Decision Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(RegisterDecisionCard, self).__init__(driver)

    #Locators - Instance members
    #self._decision = (By.NAME, "decision")
    self._decision_labels = (By.CLASS_NAME, 'decision-label')
    self._register_decision_button = (By.CLASS_NAME, 'send-email-action')
    #major_revision


   #POM Actions
  def register_decision(self, decision):
    """
    Click task completed checkbox
    decision: decision to mark, accepted values:
    'Accept', 'Reject', 'Major Revision' and 'Minor Revision'
    """
    decision_d = {'Accept':0, 'Reject':1, 'Major Revision':2, 'Minor Revision':3,}
    decision_labels = self._gets(self._decision_labels)
    decision_labels[decision_d[decision]].click()
    # click on register decision and email the author
    self._get(self._register_decision_button).click()
    time.sleep(1)
    #give some time to allow complete to check automatically,
    self.click_close_button()
    return self
