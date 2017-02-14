#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'scadavid@plos.org'

class NewTaxonCard(BaseCard):
  """
  Page Object Model for New Taxon Card
  """

  def __init__(self, driver):
    super(NewTaxonCard, self).__init__(driver)

    # Locators - Instance members
    self._questions_text = (By.CLASS_NAME, 'model-question')
    self._checkboxes = (By.XPATH, "//*[@class='question-checkbox']/input")
    self._comply_text = (By.XPATH, 
                        "//*[contains(@id, 'ember')]//*[contains(@class, 'additional-data')]//*[contains(@class, 'question-text')]/p")
    self._comply_link = (By.XPATH, 
                        "//*[contains(@id, 'ember')]//*[contains(@class, 'additional-data')]//*[contains(@class, 'question-text')]/p/a")

  # POM Actions
  def validate_card_elements_styles(self, paper_id):
    """
    This method validates the styles of the card elements including the common card elements
    :return void function
    """
    self.validate_common_elements_styles(paper_id)

  def validate_zoological_and_botanical_no_checked(self):
    """Validate if the checkboxes of zoological and botanical aren't checked"""
    zoological_checkbox, botanical_checkbox = self._gets(self._checkboxes)
    assert zoological_checkbox.is_selected() == False
    assert botanical_checkbox.is_selected() == False
    zoological_text, botanical_text = self._gets(self._questions_text)
    assert zoological_text.text == (
        "Does this manuscript describe a new zoological taxon name?"), zoological_text
    assert botanical_text.text == (
        "Does this manuscript describe a new botanical taxon name?"), botanical_text

  def validate_zoological_question_checked(self):
    """Validate if the checkbox of zoological is checked and the others aren't checked"""
    zoological_checkbox, zoological_comply_checkbox, botanical_checkbox = \
        self._gets(self._checkboxes)
    assert zoological_checkbox.is_selected() == True
    assert zoological_comply_checkbox.is_selected() == False
    assert botanical_checkbox.is_selected() == False
    self.validate_zoological_and_botanical_questions_with_zoological_comply()

  def validate_botanical_question_checked(self):
    """Validate if the checkbox of botanical is checked and the others aren't checked"""
    zoological_checkbox, botanical_checkbox, botanical_comply_checkbox = \
        self._gets(self._checkboxes)
    assert zoological_checkbox.is_selected() == False
    assert botanical_checkbox.is_selected() == True
    assert botanical_comply_checkbox.is_selected() == False
    self.validate_zoological_and_botanical_questions_with_botanical_comply()

  def validate_zoological_checkboxes(self):
    """Validate if the checkboxes of zoological are checked and the others aren't checked"""
    zoological_checkbox, zoological_comply_checkbox, botanical_checkbox = \
        self._gets(self._checkboxes)
    assert zoological_checkbox.is_selected() == True
    assert zoological_comply_checkbox.is_selected() == True
    assert botanical_checkbox.is_selected() == False
    self.validate_zoological_and_botanical_questions_with_zoological_comply()

  def validate_botanical_checkboxes(self):
    """Validate if the checkboxes of botanical are checked and the others aren't checked"""
    zoological_checkbox, botanical_checkbox, botanical_comply_checkbox = \
        self._gets(self._checkboxes)
    assert zoological_checkbox.is_selected() == False
    assert botanical_checkbox.is_selected() == True
    assert botanical_comply_checkbox.is_selected() == True
    self.validate_zoological_and_botanical_questions_with_botanical_comply()

  def validate_zoological_checkboxes_with_botanical_question(self):
    """Validate if the checkboxes of zoological are checked and botanical question is checked"""
    zoological_checkbox, zoological_comply_checkbox, \
        botanical_checkbox, botanical_comply_checkbox = self._gets(self._checkboxes)
    assert zoological_checkbox.is_selected() == True
    assert zoological_comply_checkbox.is_selected() == True
    assert botanical_checkbox.is_selected() == True
    assert botanical_comply_checkbox.is_selected() == False
    self.validate_all_text()

  def validate_botanical_checkboxes_with_zoological_question(self):
    """Validate if the checkboxes of botanical are checked and zoological question is checked"""
    zoological_checkbox, zoological_comply_checkbox, \
        botanical_checkbox, botanical_comply_checkbox = self._gets(self._checkboxes)
    assert zoological_checkbox.is_selected() == True
    assert zoological_comply_checkbox.is_selected() == False
    assert botanical_checkbox.is_selected() == True
    assert botanical_comply_checkbox.is_selected() == True
    self.validate_all_text()

  def validate_all_checkboxes(self):
    """validate all checkboxes"""
    zoological_checkbox, zoological_comply_checkbox, \
        botanical_checkbox, botanical_comply_checkbox = self._gets(self._checkboxes)
    assert zoological_checkbox.is_selected() == True
    assert zoological_comply_checkbox.is_selected() == True
    assert botanical_checkbox.is_selected() == True
    assert botanical_comply_checkbox.is_selected() == True
    self.validate_all_text()

  def validate_only_questions(self):
    """validate only the checkboxes from zoological and botanical questions"""
    zoological_checkbox, zoological_comply_checkbox, \
        botanical_checkbox, botanical_comply_checkbox = self._gets(self._checkboxes)
    assert zoological_checkbox.is_selected() == True
    assert zoological_comply_checkbox.is_selected() == False
    assert botanical_checkbox.is_selected() == True
    assert botanical_comply_checkbox.is_selected() == False
    self.validate_all_text()

  def validate_zoological_and_botanical_questions_with_zoological_comply(self):
    zoological_text, zoological_comply_text, botanical_text = self._gets(self._questions_text)
    assert zoological_text.text == (
        "Does this manuscript describe a new zoological taxon name?"), zoological_text
    assert zoological_comply_text.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), zoological_comply_text
    assert botanical_text.text == (
        "Does this manuscript describe a new botanical taxon name?"), botanical_text
    self.validate_one_link()

  def validate_zoological_and_botanical_questions_with_botanical_comply(self):
    zoological_text, botanical_text, botanical_comply_text = self._gets(self._questions_text)
    assert zoological_text.text == (
        "Does this manuscript describe a new zoological taxon name?"), zoological_text
    assert botanical_text.text == (
        "Does this manuscript describe a new botanical taxon name?"), botanical_text
    assert botanical_comply_text.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), botanical_comply_text
    self.validate_one_link()

  def validate_all_text(self):
    zoological_text, zoological_comply_text, botanical_text, botanical_comply_text = \
        self._gets(self._questions_text)
    assert zoological_text.text == (
        "Does this manuscript describe a new zoological taxon name?"), zoological_text
    assert zoological_comply_text.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), zoological_comply_text
    assert botanical_text.text == (
        "Does this manuscript describe a new botanical taxon name?"), botanical_text
    assert botanical_comply_text.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), botanical_comply_text
    self.validate_zoological_and_botanical_links()

  def validate_one_link(self):
    comply_link = self._get(self._comply_link)
    assert comply_link.get_attribute('href') == 'http://www.plosbiology.org/static/policies#taxon'

  def validate_zoological_and_botanical_links(self):
    zoological_link, botanical_link = self._gets(self._comply_link)
    assert zoological_link.get_attribute('href') == 'http://www.plosbiology.org/static/policies#taxon'
    assert botanical_link.get_attribute('href') == 'http://www.plosbiology.org/static/policies#taxon'

  def data_validation(self, data):
    """Validation of the data to log into the logging.info()"""
    if data == [False,False,False,False]:
      self.validate_zoological_and_botanical_no_checked()
    elif data == [True,False,False,False]:
      self.validate_zoological_question_checked()
    elif data == [False,False,True,False]:
      self.validate_botanical_question_checked()
    elif data == [True,True,False,False]:
      self.validate_zoological_checkboxes()
    elif data == [False,False,True,True]:
      self.validate_botanical_checkboxes()
    elif data == [True,True,True,False]:
      self.validate_zoological_checkboxes_with_botanical_question()
    elif data == [True,False,True,True]:
      self.validate_botanical_checkboxes_with_zoological_question()
    elif data == [True,True,True,True]:
      self.validate_all_checkboxes()
    elif data == [True,False,True,False]:
      self.validate_only_questions()