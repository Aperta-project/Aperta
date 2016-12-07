#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time
import urllib

from selenium.webdriver.common.by import By

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
    self._file_title = (By.CSS_SELECTOR, 'div.si-file-title')
    self._file_caption = (By.CSS_SELECTOR, 'div.si-file-caption')
   #POM Actions

  def validate_styles(self, short_doi):
    """
    Validate styles in SI Card
    """
    self.validate_common_elements_styles(short_doi)
    card_title = self._get(self._card_title)
    assert card_title.text == 'Supporting Info', card_title.text
    self.validate_application_title_style(card_title)

    msg_div = self._get(self._msg_div)
    msg = msg_div.find_elements_by_tag_name('div')[-1]
    assert msg.text == 'Please provide files in their native file formats, e.g. Word, Excel, '\
        'WAV, MPEG, JPG, etc.', card_title.text
    self.validate_application_ptext(msg)
    add_new_files_btn = self._get(self._add_new_files_btn)
    add_new_files_btn.text == "ADD FILES", add_new_files_btn.text
    self.validate_primary_big_green_button_style(add_new_files_btn)
    # Style of card elements
    file_link = self._get(self._file_link)
    self.validate_default_link_style(file_link)
    file_title = self._get(self._file_title)
    self.validate_file_title_style(file_title)
    file_caption = self._get(self._file_caption)
    self.validate_application_ptext(file_caption)

  def check_si_item(self, data):
    """
    Check if a given item is present in this card
    :return: None
    """
    file_link = self._get(self._file_link)
    assert file_link.text in data['file_name'], '{0} not in {1}'.format(file_link.text,
        data['file_name'])
    file_caption = self._get(self._file_caption)
    assert file_caption.text == data['caption'].strip(), (file_caption.text,
        data['caption'].strip())
    figure_line = '{0} {1}. {2}'.format(data['figure'], data['type'], data['title'].strip())
    file_title = self._get(self._file_title)
    assert figure_line == file_title.text, (figure_line, file_title.text)
