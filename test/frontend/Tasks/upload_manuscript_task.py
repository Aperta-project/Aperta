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
    self._intro_text = (By.CLASS_NAME, 'task-main-content')
    self._upload_manuscript_btn = (By.CLASS_NAME, 'button-primary')
    self._upload_manuscript_input = (By.ID, 'upload-files')

  # POM Actions
  def validate_styles(self, uploaded=False, pdf=False):
    """
    Validate styles in Upload Manuscript Task
    """
    intro_text = self._get(self._intro_text)
    self.validate_application_ptext(intro_text)
    assert u'You may upload a manuscript in either Microsoft Word (.docx or'\
        ' .doc) or PDF format. You can upload a replacement manuscript file at any time before'\
        ' you submit.\nMicrosoft Word format: Manuscripts uploaded in this format are suitable'\
        ' for production, and can take advantage of automatic inline figure placement and visu'\
        'al version comparison features.\nPDF format: Manuscripts uploaded in this format are '\
        'suitable for review only and will need to be accompanied by a supplemental upload of '\
        'your source document. PDF format should be used for LaTeX submissions. Additional che'\
        'cks may be required if your manuscript is accepted. If your manuscript is available i'\
        'n Microsoft Word format, please upload the original file and not a PDF, in order to m'\
        'ake use of automated figure placement and version comparison features.\n' in \
        intro_text.text, intro_text.text
    if uploaded:
      link = intro_text.find_element_by_tag_name('a')
      self.validate_default_link_style(link)
      replace = intro_text.find_element_by_tag_name('span')
      assert 'Replace' == replace.text, replace.text
      replace_icon = replace.find_element_by_tag_name('i')
      assert 'fa-refresh' in replace_icon.get_attribute('class'), \
          replace_icon.get_attribute('class')
    else:
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
      fn = os.path.join(os.getcwd(), doc2upload)
    else:
      fn = os.path.join(os.getcwd(), doc)
    logging.info('Sending document: {0}'.format(fn))
    time.sleep(1)
    self._driver.find_element_by_id('upload-files').send_keys(fn)
    upload_ms_btn = self._get(self._upload_manuscript_btn)
    upload_ms_btn.click()
    # Time needed for script execution.
    time.sleep(7)
