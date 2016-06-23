#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError, ElementExistsAssertionError
from Base.PostgreSQL import PgSQL
from frontend.Cards.basecard import BaseCard

__author__ = 'jgray@plos.org'


class TitleAbstractCard(BaseCard):
  """
  Page Object Model for the Title and Abstract Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(TitleAbstractCard, self).__init__(driver)

    #Locators - Instance members
    self._title_label = (By.CSS_SELECTOR, 'div.qa-paper-title > h3')
    self._title_textarea = (By.CSS_SELECTOR, 'div.qa-paper-title > div.form-textarea')
    self._active_title_textarea = (By.CSS_SELECTOR, 'div.qa-paper-title > div.format-input--active')
    self._title_input = (By.CSS_SELECTOR,
                         'div.qa-paper-title > div.form-textarea > div.format-input-field')
    self._abstract_label = (By. CSS_SELECTOR, 'div.qa-paper-abstract > h3')
    self._abstract_textarea = (By.CSS_SELECTOR, 'div.qa-paper-abstract > div.form-textarea')
    self._active_abstract_textarea = (By.CSS_SELECTOR,
                                      'div.qa-paper-abstract > div.format-input--active')
    self._abstract_input = (By.CSS_SELECTOR,
                            'div.qa-paper-abstract > div.form-textarea > div.format-input-field')
    self._textarea_bold_icon = (By.CSS_SELECTOR, 'i.fa-bold')
    self._textarea_italic_icon = (By.CSS_SELECTOR, 'i.fa-italic')
    self._textarea_superscript_icon = (By.CSS_SELECTOR, 'i.fa-superscript')
    self._textarea_subscript_icon = (By.CSS_SELECTOR, 'i.fa-subscript')


    #POM Actions

  def validate_styles(self):
    """
    Validate styles in the Title and Abstract Card
    :return: void function
    """
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Title And Abstract'
    self.validate_application_title_style(card_title)
    title_label = self._get(self._title_label)
    abstract_label = self._get(self._abstract_label)
    assert title_label.text == 'Title', title_label.text
    assert abstract_label.text == 'Abstract', abstract_label.text
    title_input = self._get(self._title_input)
    abstract_input = self._get(self._abstract_input)
    self.validate_application_h3_style(title_label)
    self.validate_application_h3_style(abstract_label)
    title_textarea = self._get(self._title_textarea)
    title_textarea.find_element(*self._textarea_bold_icon)
    title_textarea.find_element(*self._textarea_italic_icon)
    title_textarea.find_element(*self._textarea_superscript_icon)
    title_textarea.find_element(*self._textarea_subscript_icon)
    self.set_timeout(3)
    try:
      self._get(self._active_title_textarea)
    except ElementDoesNotExistAssertionError:
      pass
    finally:
      self.restore_timeout()
    title_input.click()
    time.sleep(2)
    self.set_timeout(3)
    try:
      self._get(self._active_title_textarea)
    finally:
      self.restore_timeout()
    abstract_textarea = self._get(self._abstract_textarea)
    abstract_textarea.find_element(*self._textarea_bold_icon)
    abstract_textarea.find_element(*self._textarea_italic_icon)
    abstract_textarea.find_element(*self._textarea_superscript_icon)
    abstract_textarea.find_element(*self._textarea_subscript_icon)
    self.set_timeout(3)
    try:
      self._get(self._active_abstract_textarea)
    except ElementDoesNotExistAssertionError:
      pass
    finally:
      self.restore_timeout()
    abstract_input.click()
    time.sleep(2)
    self.set_timeout(3)
    try:
      self._get(self._active_abstract_textarea)
    finally:
      self.restore_timeout()

  def check_initial_population(self, paper_id):
    """
    Verify that the values populated in the form are those ihat initially extracted
    :return: void function
    """
    db_title, db_abstract = PgSQL().query('SELECT title, abstract '
                                          'FROM papers '
                                          'WHERE id=%s;', (paper_id,))[0]

    extracted_title = self._get(self._title_input).text
    extracted_abstract = self._get(self._abstract_input).text
    test_title = self.compare_unicode(db_title, extracted_title)
    if not test_title:
      raise(ValueError, '{0} != {1}'.format(db_title, extracted_title))
    if db_abstract:
      clean_extracted_abstract = self.get_text(extracted_abstract.encode('utf8'))
      clean_db_abstract = self.get_text(db_abstract)
      test_abstract = self.compare_unicode(clean_db_abstract, clean_extracted_abstract)
      if not test_abstract:
        raise(ValueError, '{0} != {1}'.format(clean_db_abstract, clean_extracted_abstract))
    else:
      assert not extracted_abstract
    time.sleep(.5)

  def is_question_checked(self):
    """
    Checks if checkmark for the question on Image card is applied or not
    :return: Bool
    """
    question_check= self._get(self._question_check)
    if question_check.is_selected():
      return True
    else:
      return False

  def upload_figure(self, file_path):
    """
    Placeholder for a function to upload a tiff file in the Figures Card
    """
    pass
