#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import hashlib
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
    self._upload_source_warning = (By.CSS_SELECTOR, 'i.fa-exclamation-triangle')
    self._uploaded_pdf = (By.CSS_SELECTOR, '.task-main-content > div > a')
    self._upload_source_file_button = (By.ID, 'upload-sourcefile')
    self._upload_source_file_box = (By.CLASS_NAME, 'paper-source-upload')

  # POM Actions
  def validate_styles(self, uploaded=False, pdf=False):
    """
    Validate styles in Upload Manuscript Task.
    :param uploaded: True when there is already a paper. False when the task has no paper.
        It is needed because the text to validate is different on each case.
    :param pdf: True when a PDF is uploaded. False when not. It is needed because with the
        PDF there is a box asking for the source.
    """
    intro_text = self._get(self._intro_text)
    self.validate_application_ptext(intro_text)
    assert 'You may upload a manuscript in either Microsoft Word (.docx or .doc) or PDF format'\
        '. You can upload a replacement manuscript file at any time before you submit.\nMicros'\
        'oft Word format: Manuscripts uploaded in this format can take advantage of automatic '\
        'inline figure placement and visual version comparison features.\nPDF format: For auth'\
        'ors uploading a PDF manuscript file, figures and any SI information can be included i'\
        'n the manuscript and are not required separately for initial assessment. If a revisio'\
        'n is invited, separate figure and SI file upload will be required. If preferred, you '\
        'may upload those files separately before completing your submission.' in \
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
      assert upload_ms_btn.text == 'SELECT AND UPLOAD A DOCUMENT', upload_ms_btn.text
      self.validate_primary_big_green_button_style(upload_ms_btn)
    if pdf:
      # check for upload box
      source_file_box = self._get(self._upload_source_file_box)
      print(source_file_box.text)


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

  def take_name_of_pdf_file(self):
    """
    take_name_of_pdf_file: Take the name of the uploaded PDF
    :return: file_name as str
    """
    uploaded_pdf = self._get(self._uploaded_pdf)
    file_name, file_ext = os.path.splitext(uploaded_pdf.text)
    return file_name

  def upload_source_file(self, file_name):
    """
    upload_source_file: To upload the source file of the selected PDF
    :param: file_name is the name of the source file to be uploaded
    :return: doc2upload as str, hash_file as str
    """
    current_path = os.getcwd()
    for path in docs:
      path_without_ext = os.path.splitext(path)[0]
      if file_name in path_without_ext.split("/"):
        doc2upload = path
    fn = os.path.join(current_path, '{0}'.format(doc2upload))
    hash_file = hashlib.sha256(open(fn, 'rb').read()).hexdigest()
    logging.info('Sending document: {0}'.format(fn))
    time.sleep(1)
    self._driver.find_element_by_id('upload-source-file').send_keys(fn)
    # Time needed for script execution (file upload).
    time.sleep(7)

    return doc2upload, hash_file
