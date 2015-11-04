#!/usr/bin/env python2

import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class ReviseManuscriptCard(BaseCard):
  """
  Page Object Model for Register Decision Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(ReviseManuscriptCard, self).__init__(driver)

    #Locators - Instance members
    #self._decision_labels = (By.CLASS_NAME, 'decision-label')


   #POM Actions
  def dummy_function(self):
    """
    Paceholder function
    """
    return self
