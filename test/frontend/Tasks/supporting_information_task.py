#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.CustomException import ElementDoesNotExistAssertionError
from frontend.Tasks.basetask import BaseTask


__author__ = 'sbassi@plos.org'


class SITask(BaseTask):
  """
  Page Object Model for Supporting Information task
  """
  data = {}
  def __init__(self, driver):
    super(SITask, self).__init__(driver)

    # Locators - Instance members
    

   # POM Actions
  def validate_styles(self):
    """
    """


    return None

  def add_file(self, file_name):
    """
    This method completes the task Billing
    :param file_name: A string with a filename
    """
    self.validate_styles()
    logging.info('Attach file called with {0}'.format(file_name))
    self._driver.find_element_by_id('file_attachment').send_keys(file_name)
