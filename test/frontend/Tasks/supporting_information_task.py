#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time
import os

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from frontend.Pages.authenticated_page import application_typeface, aperta_green, aperta_black
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
    self._si_file_error_msg = (By.CLASS_NAME, 'error-message')
    self._si_file_cancel_btn = (By.CLASS_NAME, 'si-file-cancel-edit-button')
    self._si_file_save_btn = (By.CLASS_NAME, 'si-file-save-edit-button')
    self._si_file_title_caption_fields = (By.CLASS_NAME, 'format-input-field')
    self._si_file_title_display = (By.CLASS_NAME, 'si-file-title')
    self._si_file_caption_display = (By.CLASS_NAME, 'si-file-caption')
    self._si_file_del_btn = (By.CLASS_NAME, 'si-file-delete-button')
    self._si_file_other_input = (By.CLASS_NAME, 'power-select-other-input')
    self._file_link = (By.CSS_SELECTOR, 'a.si-file-filename')
   # POM Actions

  def validate_styles(self):
    """
    Validate styles for elements in Supporting Information task
    """
    self.validate_common_elements_styles()
    # btn
    upload_button = self._get(self._si_upload_btn)
    assert upload_button.text == 'ADD FILES', upload_button.text
    self.validate_primary_big_green_button_style(upload_button)

  def validate_filename_form_style(self):
    """
    Validate styles for the elements in the edit SI file
    """
    label_field = self._get(self._si_file_label_field)
    # This will fail due to APERTA-8499
    #self.validate_error_field_style(label_field)
    dropdown = self._get(self._si_file_select_category)
    assert dropdown.text == 'Select category', dropdown.text
    # This will fail due to APERTA-8499
    #self.validate_error_field_style(dropdown)
    title = self._get(self._si_file_title_input)
    assert title.text == 'Enter a title (optional)', title.text
    self.validate_input_field_style(title)
    caption = self._get(self._si_file_caption)
    assert caption.text == 'Enter a legend (optional)', caption.text
    self.validate_input_field_style(caption)
    publishable = self._get(self._si_file_publishable)
    self.validate_checkbox_label(publishable)
    assert publishable.text == 'For publication', publishable.text
    error_msg = self._get(self._si_file_error_msg)
    assert error_msg.text == 'Please edit to add label, category, and optional title '\
        'and legend', error_msg.text
    # This will fail due to APERTA-8499
    #self.validate_error_field_style(error_msg)
    cancel_btn = self._get(self._si_file_cancel_btn)
    assert cancel_btn.text == 'Cancel', cancel_btn.text
    self.validate_link_big_green_button_style(cancel_btn)
    save_btn = self._get(self._si_file_save_btn)
    assert save_btn.text == 'SAVE', save_btn.text
    self.validate_primary_error_button_style(save_btn)
    return None

  def complete_filename_form(self, data):
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
        #self._actions.move_to_element(item).click().perform()
        item.click()
        break
      elif item.text == data['type'] and data['type'] == 'Other':
        item.click()
        self._get(self._si_file_other_input).send_keys('Other')
        time.sleep(1)
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

  def validate_filename_style(self, attached_filename):
    """
    Validate styles for the uploaded file
    :param attached_filename: Element to validate
    :return: None
    """
    self.validate_default_link_style(attached_filename)
    return None

  def add_file(self, file_name):
    """
    This method completes the task Supporting Information
    :param file_name: A string with a filename
    :return: attached file name web element
    """
    logging.info('Attach file called with {0}'.format(file_name))
    self._driver.find_element_by_id('file_attachment').send_keys(file_name)
    attached_element = self._get(self._si_filename)
    return attached_element

  def add_files(self, file_list):
    """
    """
    attached_elements = []
    for file_name in file_list:
      attached_elements.append(self.add_file(file_name))
      time.sleep(3)
    return attached_elements

  def validate_uploads(self, uploads):
    """
    """
    site_uploads = self._gets(self._file_link)
    site_uploads = [x.text for x in site_uploads]
    uploads = [x.split(os.sep)[-1] for x in uploads]
    assert uploads == site_uploads, (uploads, site_uploads)
