#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

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


   # POM Actions

  def validate_styles(self):
    """
    Validate styles for elements in Supporting Information cards
    """
    self.validate_common_elements_styles()
    # btn
    upload_button = self._get(self._si_upload_btn)
    assert upload_button.text == 'ADD FILES', upload_button.text
    self.validate_primary_big_green_button_style(upload_button)

  def validate_filename_form_style(self):
    """
    """

    label_field = self._get(self._si_file_label_field)
    assert label_field.value_of_css_property('border-top-style') == 'solid', \
        label_field.value_of_css_property('border-top-style')
    assert label_field.value_of_css_property('border-top-width') == '1px', \
        label_field.value_of_css_property('border-top-width')
    assert label_field.value_of_css_property('border-top-color') == 'rgba(206, 11, 36, 1)', \
        label_field.value_of_css_property('border-top-color')
    assert label_field.value_of_css_property('border-bottom-style') == 'solid', \
        label_field.value_of_css_property('border-bottom-style')
    assert label_field.value_of_css_property('border-bottom-width') == '1px', \
        label_field.value_of_css_property('border-bottom-width')
    assert label_field.value_of_css_property('border-bottom-color') == 'rgba(206, 11, 36, 1)', \
        label_field.value_of_css_property('border-bottom-color')
    assert label_field.value_of_css_property('border-left-style') == 'solid', \
        label_field.value_of_css_property('border-left-style')
    assert label_field.value_of_css_property('border-left-width') == '1px', \
        label_field.value_of_css_property('border-left-width')
    assert label_field.value_of_css_property('border-left-color') == 'rgba(206, 11, 36, 1)', \
        label_field.value_of_css_property('border-left-color')
    assert label_field.value_of_css_property('border-right-style') == 'solid', \
        label_field.value_of_css_property('border-right-style')
    assert label_field.value_of_css_property('border-right-width') == '1px', \
        label_field.value_of_css_property('border-right-width')
    assert label_field.value_of_css_property('border-right-color') == 'rgba(206, 11, 36, 1)', \
        label_field.value_of_css_property('border-right-color')


    dropdown = self._get(self._si_file_select_category)
    assert dropdown.text == 'Select category', dropdown.text
    assert application_typeface in dropdown.value_of_css_property('font-family'), \
          dropdown.value_of_css_property('font-family')
    assert dropdown.value_of_css_property('font-size') == '14px', \
          dropdown.value_of_css_property('font-size')
    assert dropdown.value_of_css_property('font-weight') == '400', \
          dropdown.value_of_css_property('font-weight')
    assert dropdown.value_of_css_property('line-height') == '20px', \
          dropdown.value_of_css_property('line-height')
    assert dropdown.value_of_css_property('color') == 'rgba(206, 11, 36, 1)', \
          dropdown.value_of_css_property('color')


    title = self._get(self._si_file_title_input)
    assert title.text == 'Enter a title (optional)', title.text
    assert application_typeface in title.value_of_css_property('font-family'), \
          title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '14px', \
          title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '400', \
          title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '20px', \
          title.value_of_css_property('line-height')
    assert title.value_of_css_property('color') == 'rgba(85, 85, 85, 1)', \
          title.value_of_css_property('color')

    caption = self._get(self._si_file_caption)
    assert caption.text == 'Enter a legend (optional)', caption.text
    assert application_typeface in caption.value_of_css_property('font-family'), \
          caption.value_of_css_property('font-family')
    assert caption.value_of_css_property('font-size') == '14px', \
          caption.value_of_css_property('font-size')
    assert caption.value_of_css_property('font-weight') == '400', \
          caption.value_of_css_property('font-weight')
    assert caption.value_of_css_property('line-height') == '20px', \
          caption.value_of_css_property('line-height')
    assert caption.value_of_css_property('color') == 'rgba(85, 85, 85, 1)', \
          caption.value_of_css_property('color')

    publishable = self._get(self._si_file_publishable)
    assert publishable.text == 'For publication', publishable.text
    assert application_typeface in publishable.value_of_css_property('font-family'), \
          publishable.value_of_css_property('font-family')
    assert publishable.value_of_css_property('font-size') == '14px', \
          publishable.value_of_css_property('font-size')
    assert publishable.value_of_css_property('font-weight') == '400', \
          publishable.value_of_css_property('font-weight')
    assert publishable.value_of_css_property('line-height') == '20px', \
          publishable.value_of_css_property('line-height')
    assert publishable.value_of_css_property('color') == aperta_black, \
          publishable.value_of_css_property('color')

    error_msg = self._get(self._si_file_error_msg)
    assert error_msg.text == 'Please edit to add label, category, and optional title '\
        'and legend', error_msg.text
    assert application_typeface in error_msg.value_of_css_property('font-family'), \
          error_msg.value_of_css_property('font-family')
    assert error_msg.value_of_css_property('font-size') == '12px', \
          error_msg.value_of_css_property('font-size')
    assert error_msg.value_of_css_property('font-weight') == '400', \
          error_msg.value_of_css_property('font-weight')
    assert error_msg.value_of_css_property('line-height') == '17.15px', \
          error_msg.value_of_css_property('line-height')
    assert error_msg.value_of_css_property('color') == 'rgba(206, 11, 36, 1)', \
          error_msg.value_of_css_property('color')

    cancel_btn = self._get(self._si_file_cancel_btn)
    assert cancel_btn.text == 'Cancel', cancel_btn.text
    self.validate_link_big_green_button_style(cancel_btn)

    save_btn = self._get(self._si_file_save_btn)
    assert save_btn.text == 'SAVE', save_btn.text
    assert application_typeface in save_btn.value_of_css_property('font-family'), \
          save_btn.value_of_css_property('font-family')
    assert save_btn.value_of_css_property('font-size') == '14px', \
          save_btn.value_of_css_property('font-size')
    assert error_msg.value_of_css_property('font-weight') == '400', \
          save_btn.value_of_css_property('font-weight')
    assert save_btn.value_of_css_property('line-height') == '20px', \
          save_btn.value_of_css_property('line-height')
    assert save_btn.value_of_css_property('color') == 'rgba(206, 11, 36, 1)', \
          save_btn.value_of_css_property('color')
    assert save_btn.value_of_css_property('background-color') == 'rgba(255, 255, 255, 1)', \
          save_btn.value_of_css_property('background-color')

    return None


  def complete_filename_form(self, data):
    """
    """
    label_field = self._get(self._si_file_label_field)
    label_field.send_keys(data['figure'] + Keys.ENTER)
    dropdown = self._get(self._si_file_select_category)
    dropdown.click()
    parent_div = self._get((By.ID, 'ember-basic-dropdown-wormhole'))
    for item in parent_div.find_elements_by_tag_name('li'):
      if item.text == data['type']:
        item.click()
        time.sleep(1)
        break
    title = self._get(self._si_file_title_input)
    title_field = title.find_element_by_tag_name('div')
    title_field.click()
    title_field.send_keys(data['title'])

    caption = self._get(self._si_file_caption)
    caption_field = caption.find_element_by_tag_name('div')
    caption_field.click()
    caption_field.send_keys(data['caption'])
    save_btn = self._get(self._si_file_save_btn)
    save_btn.click()


  def validate_filename_style(self, attached_filename):
    """
    Validate styles for the uploaded file
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

  def add_file(self, file_name):
    """
    This method completes the task Billing
    :param file_name: A string with a filename
    return attached file name web element
    """
    ##self.validate_styles()
    logging.info('Attach file called with {0}'.format(file_name))
    self._driver.find_element_by_id('file_attachment').send_keys(file_name)
    attached_filename = self._get(self._si_filename)
    return attached_filename
