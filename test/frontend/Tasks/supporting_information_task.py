#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time
import os

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
    self._si_filename = (By.CLASS_NAME, 'si-file-filename')
    self._si_pencil_icon = (By.CLASS_NAME, 'fa-pencil')
    self._si_trash_icon = (By.CLASS_NAME, 'fa-trash')
    self._si_error_message = (By.CLASS_NAME, 'error-message')
    self._si_upload_btn = (By.CLASS_NAME, 'si-files-upload-button')
    self._si_file_label_field = (By.CLASS_NAME, 'si-file-label-field')
    self._si_file_select_category = (By.CLASS_NAME, 'si-file-category-input')
    self._si_file_title_input = (By.CLASS_NAME, 'si-file-title-input')
    self._si_file_caption = (By.CLASS_NAME, 'si-file-caption-textbox')
    self._si_file_publishable = (By.CLASS_NAME, 'si-file-publishable-checkbox')
    self._si_file_cancel_btn = (By.CLASS_NAME, 'si-file-cancel-edit-button')
    self._si_file_save_btn = (By.CLASS_NAME, 'si-file-save-edit-button')
    self._si_file_title_caption_fields = (By.CLASS_NAME, 'format-input-field')
    self._si_file_title_display = (By.CLASS_NAME, 'si-file-title')
    self._si_file_caption_display = (By.CLASS_NAME, 'si-file-caption')
    self._si_file_del_btn = (By.CLASS_NAME, 'si-file-delete-button')
    self._si_file_other_input = (By.CLASS_NAME, 'power-select-other-input')
    self._file_link = (By.CSS_SELECTOR, 'a.si-file-filename')
    self._si_file_view = (By.CLASS_NAME, 'si-file-view')
    # Change followin markers when APERTA-8609 is addressed
    self._si_task_main_content = (By.CLASS_NAME, 'task-main-content')
    self._si_replace_div = (By.CSS_SELECTOR, 'div.fileinput-button')
    self._si_replace_input = (By.CSS_SELECTOR, 'input.ember-text-field')
    self._si_green_spinner = (By.CLASS_NAME, 'progress-spinner--green')
    self._si_file_link = (By.CLASS_NAME, 'si-file-filename')
   # POM Actions

  def validate_styles(self):
    """
    Validate styles for elements in Supporting Information task
    :return: None
    """
    self.validate_common_elements_styles()
    task_main_content = self._get(self._si_task_main_content)
    # Requested non positional locator at APERTA-8609
    upload_msg = task_main_content.find_elements_by_tag_name('div')[2]
    self.validate_application_ptext(upload_msg)
    assert upload_msg.text == 'Please provide files in their native file formats, e.g. '\
        'Word, Excel, WAV, MPEG, JPG, etc.', upload_msg.text
    upload_button = self._get(self._si_upload_btn)
    assert upload_button.text == 'ADD FILES', upload_button.text
    self.validate_primary_big_green_button_style(upload_button)

  def validate_si_edit_form_style(self, empty=True):
    """
    Validate styles for the elements in the edit SI file
    :param empty: Bool to tell if the form is empty before validation. The empty form
        has prepopulated (placeholders) fields that have to be checked.
    :return: None
    """
    label_field = self._get(self._si_file_label_field)
    # This will fail due to APERTA-8499
    #self.validate_error_field_style(label_field)
    dropdown = self._get(self._si_file_select_category)
    # This will fail due to APERTA-8499
    #self.validate_error_field_style(dropdown)
    title = self._get(self._si_file_title_input)
    self.validate_input_field_style(title)
    caption = self._get(self._si_file_caption)
    self.validate_input_field_style(caption)
    publishable = self._get(self._si_file_publishable)
    self.validate_checkbox_label(publishable)
    save_btn = self._get(self._si_file_save_btn)
    assert save_btn.text == 'SAVE', save_btn.text
    if empty:
      assert dropdown.text == 'Select category', dropdown.text
      assert title.text == 'Enter a title', title.text
      assert caption.text == 'Enter a legend (optional)', caption.text
      assert publishable.text == 'For publication', publishable.text
      error_msg = self._get(self._si_error_message)
      assert error_msg.text == 'Please edit to add label, category, and optional title '\
          'and legend', error_msg.text
      self.validate_primary_error_button_style(save_btn)
    # This will fail due to APERTA-8499
    #self.validate_error_field_style(error_msg)
    cancel_btn = self._get(self._si_file_cancel_btn)
    assert cancel_btn.text == 'Cancel', cancel_btn.text
    self.validate_link_big_green_button_style(cancel_btn)
    return None

  def complete_si_item_form(self, data):
    """
    Complete the form associated with a file
    :param data: Dictionary with the following keys: figure, type, title and caption
    :return: None
    """
    label_field = self._get(self._si_file_label_field)
    label_field.clear()
    label_field.send_keys(data['figure'] + Keys.ENTER)
    dropdown = self._get(self._si_file_select_category)
    dropdown.click()
    parent_div = self._get((By.ID, 'ember-basic-dropdown-wormhole'))
    for item in parent_div.find_elements_by_tag_name('li'):
      if item.text == data['type'] and data['type'] != 'Other':
        item.click()
        break
      elif item.text == data['type'] and data['type'] == 'Other':
        item.click()
        self._get(self._si_file_other_input).send_keys('Other')
        break
    title = self._get(self._si_file_title_input)
    title_field = title.find_element_by_tag_name('div')
    title_field.click()
    title_field.clear()
    title_field.send_keys(data['title'])
    caption = self._get(self._si_file_caption)
    caption_field = caption.find_element_by_tag_name('div')
    caption_field.click()
    caption_field.clear()
    caption_field.send_keys(data['caption'])
    save_btn = self._get(self._si_file_save_btn)
    save_btn.click()
    return None

  def add_file(self, file_name):
    """
    Add a file to the Supporting Information task
    :param file_name: A string with a filename
    :return: None
    """
    logging.info('Attach file called with {0}'.format(file_name))
    sif = (By.CLASS_NAME, 'si-file-view')
    try:
      sif_before  = len(self._gets(sif))
    except ElementDoesNotExistAssertionError:
      sif_before = 0
    self._driver.find_element_by_id('file_attachment').send_keys(file_name)
    # Time needed for file upload
    counter = 0
    sif_after = len(self._gets(sif))
    while sif_after <= sif_before:
      sif_after = len(self._gets(sif))
      counter += 1
      if counter > 60:
        break
      time.sleep(1)

  def add_files(self, file_list):
    """
    Add files to the SI task. This method calls add_file for each file it adds
    :param file_list: A list with strings with a filename
    :return: None
    """
    for file_name in file_list:
      self.add_file(file_name)
      # Sleep avoid a Stale Element Reference Exception
      time.sleep(5)

  def validate_uploads(self, uploads):
    """
    Give a list of file, check if they are opened in the SI task
    Note that order may not be preserved so I compare an unordered set
    :param uploads: Iterable with string with the file name to check in SI task
    :return: None
    """
    site_uploads = self._gets(self._file_link)
    timeout = 15
    counter = 0
    while len(uploads) != len(site_uploads) or counter == timeout:
      site_uploads = self._gets(self._file_link)
      # give time for uploading file to end processing
      time.sleep(1)
      counter += 1
    site_uploads = set([x.text for x in site_uploads])
    uploads = set([x.split(os.sep)[-1].replace(' ', '+') for x in uploads])
    assert uploads == site_uploads, (uploads, site_uploads)
    return None

  def validate_upload(self, upload):
    """
    Given a file name, check if it is opened in the SI task
    :param upload: String with the file name to check in SI task
    :return: None
    """
    site_upload = self._get(self._si_filename).find_element_by_tag_name('a').text
    assert site_upload.replace(' ', '+') in upload, (upload, site_upload.replace(' ', '+'))
    return None

  def validate_uploads_styles(self, attached_filename):
    """
    Validate the style of the upload elements in the SI task. Task must be opened
    to run this method
    :param uploads: File name to check styles
    :return: None
    """
    self.validate_default_link_style(attached_filename)
    edit_btn = self._get(self._si_pencil_icon)
    edit_btn.click()
    self.validate_si_edit_form_style(False)
    cancel_btn = self._get(self._si_file_cancel_btn)
    cancel_btn.click()
