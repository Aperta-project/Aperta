#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random
import time

from selenium.webdriver.common.by import By

from Base.Resources import docs
from frontend.Tasks.basetask import BaseTask

__author__ = 'jgray@plos.org'

class UploadManuscriptTask(BaseTask):
  """
  Page Object Model for Upload Manuscript task
  """

  def __init__(self, driver, url_suffix='/'):
    super(UploadManuscriptTask, self).__init__(driver)

    #Locators - Instance members
    self._intro_text = (By.TAG_NAME, 'p')
    self._upload_manuscript_btn = (By.CLASS_NAME, 'button-primary')
    self._upload_manuscript_input = (By.ID, 'upload-files')

  # POM Actions
  def validate_styles(self):
    """
    Validate styles in Upload Manuscript Task
    """
    intro_text = self._get(self._intro_text)
    self.validate_application_ptext(intro_text)
    assert intro_text.text == 'You may upload a manuscript at any time.', intro_text.text
    upload_ms_btn = self._get(self._upload_manuscript_btn)
    assert upload_ms_btn.text == 'SELECT AND UPLOAD A DOCUMENT'
    self.validate_primary_big_green_button_style(upload_ms_btn)

  def upload_manuscript(self, doc='random'):
    """
    Function to upload a doc/docx file
    :param doc: Name of the document to upload. If blank will default to 'random', this will choose
      one of available papers
    :return void function
    """
    if doc == 'random':
      doc2upload = random.choice(docs)
      fn = os.path.join(os.getcwd(), 'frontend/assets/docs/{0}'.format(doc2upload))
    else:
      fn = os.path.join(os.getcwd(), 'frontend/assets/docs/', doc)
    logging.info('Sending document: {0}'.format(fn))
    time.sleep(1)
    self._driver.find_element_by_id('upload-files').send_keys(fn)
    upload_ms_btn = self._get(self._upload_manuscript_btn)
    upload_ms_btn.click()
    # Time needed for script execution.
    time.sleep(7)
