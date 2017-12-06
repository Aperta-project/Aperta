#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import hashlib
import logging
import os
import random
import time

from selenium.webdriver.common.by import By

from Base.Resources import docs
from Base.CustomException import ElementDoesNotExistAssertionError
from frontend.Tasks.basetask import BaseTask

__author__ = 'jgray@plos.org'


class UploadManuscriptTask(BaseTask):
  """
  Page Object Model for Upload Manuscript task
  """

  def __init__(self, driver, url_suffix='/'):
    super(UploadManuscriptTask, self).__init__(driver)

    # Locators - Instance members
    self._intro_text = (By.CLASS_NAME, 'task-main-content')
    self._upload_manuscript_btn = (By.CLASS_NAME, 'button-primary')
    self._upload_manuscript_replace_btn = (By.CLASS_NAME, 'replace-attachment')
    self._upload_manuscript_input = (By.ID, 'upload-files')
    self._upload_source_warning = (By.CSS_SELECTOR,
                                   'div.card-content-view-text + div.card-content-file-uploader '
                                   '+ div.ember-view div.error-message i.fa-exclamation-triangle')
    self._uploaded_pdf = (By.CSS_SELECTOR, 'a.file-link')
    self._upload_source_file_button = (By.ID, 'upload-files')
    self._uploaded_file_box = (By.CSS_SELECTOR, 'div.task-main-content>.card-content-file-uploader')
    self._upload_source_file_box = (By.CSS_SELECTOR, 'div.custom-card-task  .card-content-if '
                                                     '+ .card-content-file-uploader '
                                                     '+ .card-content-if')
    self._link_to_file = (By.CSS_SELECTOR, 'div.attachment-item>a.file-link')
    self._link_to_source_file = (By.CSS_SELECTOR, 'div.card-content-if a.file-link')

  # POM Actions
  def validate_styles(self, type_='doc', source_uploaded=False):
    """
    Validate styles in Upload Manuscript Task.
    :param type_: Document type ('doc' or 'pdf')
    :param source_uploaded: Boolean. Styles change when the source is uploaded
    """
    intro_text = self._get(self._intro_text)
    self.validate_application_body_text(intro_text)
    assert 'You may upload a manuscript in either Microsoft Word (.docx or .doc) or PDF format. ' \
           'You can upload a replacement manuscript file at any time before you submit.\n' \
           'Microsoft Word format: Manuscripts uploaded in this format can take advantage of ' \
           'automatic inline figure placement and visual version comparison features.\nPDF ' \
           'format: For authors uploading a PDF manuscript file, figures and any SI information ' \
           'can be included in the manuscript and are not required separately for initial ' \
           'assessment. If a revision is invited, separate figure and SI file upload will be ' \
           'required. If preferred, you may upload those files separately before completing your ' \
           'submission.' in intro_text.text, 'Upload ms message: {0} is not the ' \
                                             'expected copy'.format(intro_text.text)
    link = intro_text.find_element(*self._file_link)
    self.validate_filename_link_style(link)
    replace = intro_text.find_element(*self._replace_file_link)
    assert 'Replace' == replace.text, replace.text
    replace_icon = replace.find_element_by_tag_name('i')
    assert 'fa-refresh' in replace_icon.get_attribute('class'), \
        replace_icon.get_attribute('class')
    if type_ == 'pdf':
      source_file_box = self._get(self._upload_source_file_box)
      logging.info(source_file_box.text)
      assert 'Please Upload Your Source File\nBecause you uploaded a PDF, you must also provide ' \
             'your source file (e.g. .tex, .docx) before marking this task as done.' \
             in source_file_box.text, source_file_box.text
      if source_uploaded:
        # It is inadvisable to use find by method, the correct way to do this is do an _get()
        link = source_file_box.find_element(*self._file_link)
        self.validate_filename_link_style(link)
        replace = source_file_box.find_element(*self._replace_file_link)
        assert 'Replace' == replace.text, replace.text
        # It is inadvisable to use find by method, the correct way to do this is do an _get()
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
    source_input = self._get(self._upload_manuscript_input)
    source_input.send_keys(fn)
    self._wait_for_text_be_present_in_element(self._link_to_file, fn.split('/')[-1])
    self.set_timeout(3)
    try:
      upload_ms_btn = self._get(self._upload_manuscript_btn)
    except ElementDoesNotExistAssertionError:
      upload_ms_btn = self._get(self._upload_manuscript_replace_btn)
    self.restore_timeout()
    upload_ms_btn.click()
    self._wait_for_text_be_present_in_element(self._link_to_file, fn.split('/')[-1])
    # Time needed for script execution.
    time.sleep(7)

  def replace_manuscript(self, doc='random'):
    """
    Function to replace an uploaded doc/docx/pdf file
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
    # If the originally uploaded file was a doc/docx there will be no upload source file bits
    # If it was a pdf, you need to upload to complete card
    skip_source_upload = False
    try:
      upload_source_file_btn = self._get(self._upload_source_file_button)
    except ElementDoesNotExistAssertionError:
      skip_source_upload = True
    if not skip_source_upload:
      self._scroll_into_view(upload_source_file_btn)
      upload_source_file_btn.send_keys(fn)
      self._wait_for_text_be_present_in_element(self._link_to_source_file, fn.split('/')[-1])
      # Time needed for script execution.
      time.sleep(10)

  def take_name_of_pdf_file(self):
    """
    take_name_of_pdf_file: Take the name of the uploaded PDF
    :return: file_name as str
    """
    self._scroll_into_view(self._get(self._uploaded_pdf))
    uploaded_pdf = self._get(self._uploaded_pdf)
    file_name, file_ext = os.path.splitext(uploaded_pdf.text)
    full_file_name = '{0}{1}'.format(file_name, file_ext)
    return full_file_name

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
      doc2upload = 'frontend/assets/docs/{0}'.format(file_name)
      doc2upload_wihout_ext = os.path.splitext(doc2upload)[0]
      current_path = os.getcwd()
      fn = '{0}/{1}.doc'.format(current_path, doc2upload_wihout_ext)
      fn_docx = '{0}/{1}.docx'.format(current_path, doc2upload_wihout_ext)
    try:
      with open(fn, 'rb') as fh:
        hash_file = hashlib.sha256(fh.read()).hexdigest()
      logging.info('Sending document: {0}'.format(fn))
      time.sleep(1)
      source_input = self._get(self._upload_manuscript_input)
      source_input.send_keys(fn)
      file_ext = 'doc'
    except IOError:
      with open(fn_docx, 'rb') as fh:
        hash_file = hashlib.sha256(fh.read()).hexdigest()
      logging.info('Sending document: {0}'.format(fn_docx))
      time.sleep(1)
      source_input = self._get(self._upload_manuscript_input)
      source_input.send_keys(fn_docx)
      file_ext = 'docx'
    # Time needed for script execution (file upload).
    name_without_ext = ((fn.split('/')[-1])).split('.')[0]
    self._wait_for_text_be_present_in_element(self._link_to_source_file, name_without_ext)
    time.sleep(7)
    return file_name, hash_file, file_ext
