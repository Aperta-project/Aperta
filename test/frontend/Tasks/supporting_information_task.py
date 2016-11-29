#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from frontend.Pages.authenticated_page import application_typeface, aperta_green
from Base.CustomException import ElementDoesNotExistAssertionError
from frontend.Tasks.basetask import BaseTask


#/home/sbassi/projects/plos/tahi-integration/frontend/Pages/authenticated_page.py

__author__ = 'sbassi@plos.org'


class SITask(BaseTask):
  """
  Page Object Model for Supporting Information task
  """
  data = {}
  def __init__(self, driver):
    super(SITask, self).__init__(driver)

    # Locators - Instance members
    self._si_filename = (By.CLASS_NAME, 'si-file-filename')
    self._si_pencil_icon = (By.CLASS_NAME, 'fa-pencil')
    self._si_trash_icon = (By.CLASS_NAME, 'fa-trash')
    self._si_error_message = (By.CLASS_NAME, 'error-message')

   # POM Actions

  def validate_styles(self):
    """
    """
    self.validate_common_elements_styles()



  def validate_filename_style(self, attached_filename):
    """
    """
    assert application_typeface in attached_filename.value_of_css_property('font-family'), \
        attached_filename.value_of_css_property('font-family')
    assert attached_filename.value_of_css_property('font-size') == '14px', \
        attached_filename.value_of_css_property('font-size')
    assert attached_filename.value_of_css_property('font-weight') == '400', \
        attached_filename.value_of_css_property('font-weight')
    assert attached_filename.value_of_css_property('line-height') == '20px', \
        attached_filename.value_of_css_property('line-height')
    assert attached_filename.value_of_css_property('color') == aperta_green, \
        attached_filename.value_of_css_property('color')
    return None



    #upload_ms_btn = self._get(self._upload_manuscript_btn)
    #assert upload_ms_btn.text == 'SELECT AND UPLOAD A DOCUMENT'
    #self.validate_primary_big_green_button_style(upload_ms_btn)



  def add_file(self, file_name):
    """
    This method completes the task Billing
    :param file_name: A string with a filename
    """
    ##self.validate_styles()
    logging.info('Attach file called with {0}'.format(file_name))
    self._driver.find_element_by_id('file_attachment').send_keys(file_name)
    attached_filename = self._get(self._si_filename)
    return attached_filename
