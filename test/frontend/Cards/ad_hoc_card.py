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

from frontend.Pages.authenticated_page import APERTA_GREY_DARK
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
    self._tb_check = (By.CLASS_NAME, 'adhoc-toolbar-item--list')
    self._tb_text = (By.CLASS_NAME, 'adhoc-toolbar-item--text')
    self._tb_paragraph = (By.CLASS_NAME, 'adhoc-toolbar-item--label')
    self._tb_email = (By.CLASS_NAME, 'adhoc-toolbar-item--email')
    self._tb_image = (By.CLASS_NAME, 'adhoc-toolbar-item--image')
    self._text_text_area = (By.CSS_SELECTOR,
        'div.inline-edit-body-part div.bodypart-display div.content-editable-muted')
    #self._text_delete_icon = (By.CSS_SELECTOR, 'div.view-actions span.fa-trash')
    self._text_delete_icon = (By.CSS_SELECTOR, 'span.fa-trash')

    #list
    self._chk_item_remove = (By.CLASS_NAME, 'item-remove')
    self._chk_cancel_lnk = (By.CSS_SELECTOR, 'div.edit-actions div.button-link')
    self._chk_save_btn = (By.CSS_SELECTOR, 'div.edit-actions div.button-secondary')
    self._chk_add_btn = (By.CSS_SELECTOR, 'div.inline-edit-body-part div.add-item')

    self._delete_warning = (By.CSS_SELECTOR, 'div.bodypart-destroy-overlay h4')
    self._cancel_warning = (By.CSS_SELECTOR, 'div.bodypart-destroy-overlay button.button--white')
    self._delete_btn = (By.CSS_SELECTOR, 'div.bodypart-destroy-overlay button.delete-button')

    self._paragraph_form = (By.CSS_SELECTOR, 'div.inline-edit-form div.editable')
    self._cancel_lnk = (By.CLASS_NAME, 'cancel-block')
    self._save_btn = (By.CSS_SELECTOR, 'div.save-block')

    self._email_subject = (By.CSS_SELECTOR, 'div.email input.ember-text-field')

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
    if role == 'Staff Only':
      role = 'Staff-only'
    corresponding_role = 'Corresponding Role {0}'.format(role)
    assert subtitle.text in corresponding_role, '{0} not in {1}'.format(subtitle.text,
        corresponding_role)
    self.validate_application_ptext(subtitle)
    add_btn = self._get(self._add_btn)
    self.validate_primary_big_green_button_style(add_btn)
    self._get(self._plus_icon)
    return None

  def test_controller(self, control):
    """
    """
    if control == 'check':
      self._get(self._tb_check).click()
      self._get(self._chk_item_remove)
      cancel_lnk = self._get(self._chk_cancel_lnk)
      assert cancel_lnk.text == 'cancel', cancel_lnk.text
      self.validate_link_big_green_button_style(cancel_lnk)
      save_btn = self._get(self._chk_save_btn)
      assert save_btn.text == 'SAVE', save_btn.text
      # Disabled due to APERTA-9063
      #self.validate_secondary_big_disabled_button_style(save_btn)
      chk_add_btn = self._get(self._chk_add_btn)
      # can't validate PLUS sign style due to APERTA-XXXX
    elif control == 'input_text':
      self._get(self._tb_text).click()
      placeholder_text = self._get(self._text_text_area).text
      assert placeholder_text == u'Click to type in your response.', placeholder_text
      self._get(self._text_text_area).click()
      self._wait_for_element(self._get(self._text_delete_icon))
      delete_icon = self._get(self._text_delete_icon)
      #self._actions.move_to_element(delete_icon).perform()
      delete_icon.click()
      # Dissabled due to APERTA-9139
      #assert delete_icon.value_of_css_property('color') == APERTA_GREY_DARK, \
      #    delete_icon.value_of_css_property('color')
      #self._actions.move_to_element(delete_icon).perform()
      #delete_icon = self._get(self._text_delete_icon)
      #self._wait_for_element(self._get(self._text_delete_icon))
      #self._get(self._text_delete_icon).click()
      # Dissabled due to APERTA-9139
      #assert delete_icon.value_of_css_property('color') == u'rgba(15, 116, 0, 1)', \
      #    delete_icon.value_of_css_property('color')
      delete_warning = self._get(self._delete_warning)
      warning_msg = 'This will permanently delete your item. Are you sure?'
      self.validate_warning_message_style(delete_warning, warning_msg)
      cancel_lnk = self._get(self._cancel_warning)
      self.validate_cancel_confirmation_style(cancel_lnk)
      delete_btn = self._get(self._delete_btn)
      self.validate_delete_confirmation_style(delete_btn)


    elif control == 'paragraph':
      self._get(self._tb_paragraph).click()
      cancel_lnk = self._get(self._cancel_lnk)
      assert cancel_lnk.text == 'cancel', cancel_lnk.text
      self.validate_cancel_link_style(cancel_lnk)
      save_btn = self._get(self._save_btn)
      assert save_btn.text == 'SAVE', save_btn.text
      # Disabled due to APERTA-9063
      #self.validate_secondary_big_green_button_style(save_btn)
      # Dissabled due to APERTA-9167
      #self._get(self._paragraph_form)
    elif control == 'email':
      self._get(self._tb_email).click()

      subject = self._get(self._email_subject)
      assert subject.get_attribute('placeholder') == 'Enter a subject', \
        subject.get_attribute('placeholder')
      cancel_lnk = self._get(self._chk_cancel_lnk)
      assert cancel_lnk.text == 'cancel', cancel_lnk.text
      self.validate_link_big_green_button_style(cancel_lnk)
      save_btn = self._get(self._save_btn)
      assert save_btn.text == 'SAVE', save_btn.text
      # Disabled due to APERTA-9063
      #self.validate_secondary_big_green_button_style(save_btn)
    elif control == 'file_upload':
      self._get(self._tb_image).click()
      import pdb; pdb.set_trace()
