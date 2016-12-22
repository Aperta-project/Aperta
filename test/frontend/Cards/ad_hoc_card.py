#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import re
import time
import os
import random

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from Base.CustomException import ElementDoesNotExistAssertionError, ElementExistsAssertionError
from Base.PostgreSQL import PgSQL
from Base.Resources import docs, supporting_info_files, figures, pdfs
from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class AHCard(BaseCard):
  """
  Abstract class for Page Object Model of all types of Ad-Hoc Cards
  """
  def __init__(self, driver):
    super(AHCard, self).__init__(driver)

    # Locators - Instance members
    self._card_title = (By.CSS_SELECTOR, 'h1.inline-edit')
    self._edit_title = (By.CSS_SELECTOR, 'h1 span.fa-pencil')
    self._subtitle = (By.CLASS_NAME, 'ad-hoc-corresponding-role')
    self._add_btn = (By.CSS_SELECTOR, 'div.adhoc-content-toolbar div.button--green')
    self._plus_icon = (By.CLASS_NAME, 'fa-plus')
    self._tb_list = (By.CLASS_NAME, 'adhoc-toolbar-item--list')
    self._tb_text = (By.CLASS_NAME, 'adhoc-toolbar-item--text')
    self._tb_label = (By.CLASS_NAME, 'adhoc-toolbar-item--label')
    self._tb_email = (By.CLASS_NAME, 'adhoc-toolbar-item--email')
    self._tb_image = (By.CLASS_NAME, 'adhoc-toolbar-item--image')

  # POM Actions
  def validate_card_elements_styles(self, short_doi, role):
    """
    Style check for the card
    :param role: String with the role the card is made for
    :param short_doi: Used to pass through to validate_common_elements_styles
    :return None
    """
    self.validate_common_elements_styles(short_doi)
    title = self._get(self._card_title)
    self.validate_application_title_style(title)
    role_title = 'Ad-hoc for {0}'.format(role)
    assert title.text == role_title, (title.text, role_title)
    assert self._get(self._edit_title)
    subtitle = self._get(self._subtitle)
    assert subtitle.text in 'Corresponding Role {0}'.format(role), subtitle.text
    self.validate_application_ptext(subtitle)
    add_btn = self._get(self._add_btn)
    self.validate_primary_big_green_button_style(add_btn)
    self._get(self._plus_icon)
    return None
