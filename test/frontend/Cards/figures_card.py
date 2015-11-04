#!/usr/bin/env python2

import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class FiguresCard(BaseCard):
  """
  Page Object Model for Register Decision Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(FiguresCard, self).__init__(driver)

    #Locators - Instance members
    self._decision_labels = (By.CLASS_NAME, 'decision-label')
    self._register_decision_button = (By.CLASS_NAME, 'send-email-action')


   #POM Actions
  def upload_figure(self, file_path):
    """
    """

    self.click_close_button()
    #self._get(self._completed_check).click()
    return self
