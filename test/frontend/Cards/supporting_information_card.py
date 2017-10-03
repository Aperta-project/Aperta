#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import logging
import os
import time
import urllib

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError
from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class SICard(BaseCard):
  """
  Page Object Model for Supporting Information Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(SICard, self).__init__(driver)

    #Locators - Instance members
    self._card_title = (By.TAG_NAME, 'h1')
    self._msg_div = (By.CLASS_NAME, 'task-main-content')
    self._add_new_files_btn = (By.CLASS_NAME, 'fileinput-button')
    self._file_link = (By.CSS_SELECTOR, 'a.si-file-filename')
    self._upload_help_text = (By.CSS_SELECTOR, 'span.button-primary + div')
    self._si_filename = (By.CLASS_NAME, 'si-file-filename')
   #POM Actions

  def validate_styles(self, short_doi):
    """
    Validate styles in SI Card
    :param short_doi: String with the short DOI
    :return: None
    """
    self.validate_common_elements_styles(short_doi)
    card_title = self._get(self._card_title)
    assert card_title.text == 'Supporting Info', card_title.text
    self.validate_overlay_card_title_style(card_title)

    msg = self._get(self._upload_help_text)
    assert msg.text == 'Please provide files in their native file formats, e.g. Word, Excel, '\
        'WAV, MPEG, JPG, etc.', card_title.text
    self.validate_application_body_text(msg)
    add_new_files_btn = self._get(self._add_new_files_btn)
    assert add_new_files_btn.text == 'ADD FILES', add_new_files_btn.text
    self.validate_primary_big_green_button_style(add_new_files_btn)
    # Style of card elements
    file_link = self._get(self._file_link)
    self.validate_default_link_style(file_link)

  def check_si_item(self, data):
    """
    Check if a given item is present in this card
    :param data: Dictionary with the following keys: file_name, figure, title, type and caption
    :return: None
    """
    file_link = self._get(self._file_link)
    assert file_link.text in urllib.parse.quote_plus(data['file_name']), \
        '{0} not in {1}'.format(file_link.text, urllib.parse.quote_plus(data['file_name']))

  def validate_uploads(self, uploads):
    """
    Give a list of file, check if they are opened in the SI card
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

  def validate_upload(self, upload):
    """
    Give a list of file, check if they are opened in the SI task
    Note that order may not be preserved so I compare an unordered set
    :param upload: Iterable with string with the file name to check in SI task
    :return: None
    """
    site_upload = self._get(self._file_link).text
    assert site_upload.replace(' ', '+') in upload, (upload, site_upload.replace(' ', '+'))
    return None

  def add_file(self, file_name):
    """
    Add a file to the Supporting Information card
    :param file_name: A string with a filename
    :return: None
    """
    logging.info('Attach file called with {0}'.format(file_name))
    sif = (By.CLASS_NAME, 'si-file-view')
    try:
      sif_before = len(self._gets(sif))
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
    Add files to the SI card. This method calls add_file for each file it adds
    :param file_list: A list with strings with a filename
    :return: None
    """
    for file_name in file_list:
      new_element = self.add_file(file_name)
      # This sleep avoid a Stale Element Reference Exception
      time.sleep(12)
    return None