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
  def validate_styles(self, type_='doc', source_uploaded=False):
    """
    Validate styles in Upload Manuscript Task.
    :param type_: Document type ('doc' or 'pdf')
    :source_uploaded: Boolean. Styles change when the source is uploaded
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
        intro_text.text, 'Upload ms message: {0} is not the expected'.format(intro_text.text)
    #if uploaded:
    link = intro_text.find_element_by_tag_name('a')
    self.validate_default_link_style(link)
    replace = intro_text.find_element_by_tag_name('span')
    assert 'Replace' == replace.text, replace.text
    replace_icon = replace.find_element_by_tag_name('i')
    assert 'fa-refresh' in replace_icon.get_attribute('class'), \
        replace_icon.get_attribute('class')
    if type_=='pdf':
      source_file_box = self._get(self._upload_source_file_box)
      source_file_box.text == 'Please Upload Your Source File\nBecause you uploaded a PDF, you m'\
      'ust also provide your source file (e.g. .tex, .docx) before marking this task as done.\nU'\
      'PLOAD SOURCE FILE', source_file_box.text
      if source_uploaded:
        link = source_file_box.find_element_by_tag_name('a')
        self.validate_default_link_style(link)
        replace = source_file_box.find_element_by_tag_name('span')
        assert 'Replace' == replace.text, replace.text
        replace_icon = replace.find_element_by_tag_name('i')
        assert 'fa-refresh' in replace_icon.get_attribute('class'), \
            replace_icon.get_attribute('class')
      elif not source_uploaded:
        upload_source_btn = self._get(self._upload_source_file_button)
        upload_source_btn.text == 'UPLOAD SOURCE FILE', '{0} not UPLOAD SOURCE FILE'.format(
            upload_source_btn.text)
        self.validate_secondary_big_green_button_style(upload_source_btn)




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

  def upload_source_file(self, file_name='random'):
    """
    upload_source_file: To upload the source file of the selected PDF
    :param: file_name is the name of the source file to be uploaded
    :return: a tuple with doc2upload as str and hash_file as str
    """
    '''
    current_path = os.getcwd()
    for path in docs:
      path_without_ext = os.path.splitext(path)[0]
      if file_name in path_without_ext.split("/"):
        doc2upload = path
    fn = os.path.join(current_path, doc2upload)
    '''
    if file_name == 'random':
      doc2upload = random.choice(docs)
      fn = os.path.join(os.getcwd(), doc2upload)
    else:
      doc2upload = file_name
      fn = os.path.join(os.getcwd(), file_name)
    with open(fn, 'rb') as fh:
      hash_file = hashlib.sha256(fh.read()).hexdigest()
    logging.info('Sending document: {0}'.format(fn))
    time.sleep(1)
    self._driver.find_element_by_id('upload-source-file').send_keys(fn)
    # Time needed for script execution (file upload).
    time.sleep(7)
    return doc2upload, hash_file
