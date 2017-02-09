#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time
import random

from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask

__author__ = 'scadavid@plos.org'

class NewTaxonTask(BaseTask):
  """
  Page Object Model for New Taxon Task
  """

  def __init__(self, driver):
    super(NewTaxonTask, self).__init__(driver)

    # Locators - Instance members
    self._questions_text = (By.CLASS_NAME, 'model-question')
    self._checkboxes = (By.XPATH, "//*[@class='question-checkbox']/input")
    self._comply_text = (By.XPATH, 
                        "//*[contains(@id, 'ember')]//*[contains(@class, 'additional-data')]//*[contains(@class, 'question-text')]/p")
    self._comply_link = (By.XPATH, 
                        "//*[contains(@id, 'ember')]//*[contains(@class, 'additional-data')]//*[contains(@class, 'question-text')]/p/a")
  
  # POM Actions
  def zoological_and_botanical_first_question_without_checkboxes(self):
    """Validate zoological and botanical first question without _checkboxes"""
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_text, botanical_text = self._gets(self._questions_text)
    assert zoological_text.text == (
        "Does this manuscript describe a new zoological taxon name?"), zoological_text
    assert botanical_text.text == (
      "Does this manuscript describe a new botanical taxon name?"), botanical_text

  def zoological_and_botanical_first_question_with_one_checked(self, position_checkbox):
    """
    Validate zoological and botanical first question with zoological checked
    Validate zoological and botanical first question with botanical checked
    :param position_checkbox: The position to extract the information needed for the _checkboxes
    """
    self.zoological_and_botanical_first_question_without_checkboxes()
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    checkbox = self._gets(self._checkboxes)[position_checkbox]
    checkbox.click()
    comply_text = self._gets(self._comply_text)
    assert comply_text.text == (
        "Please read Regarding Submission of a new Taxon Name and indicate if you comply:"), \
        comply_text
    comply_link = self._gets(self._comply_link)
    assert comply_link.get_attribute('href') == 'http://www.plosbiology.org/static/policies#taxon'
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    authors_comply = self._gets(self._questions_text)
    assert authors_comply.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), \
        authors_comply

  def zoological_and_botanical_first_question_with_zoological_comply_accepted(self):
    """Validate zoological and botanical first question with zoological checked and comply accepted"""
    self.zoological_and_botanical_first_question_with_one_checked(0)
    self.zoological_and_botanical_comply_checkbox_helper(1)

  def zoological_and_botanical_first_question_with_botanical_comply_accepted(self):
    """Validate zoological and botanical first question with botanical checked and comply accepted"""
    self.zoological_and_botanical_first_question_with_one_checked(1)
    self.zoological_and_botanical_comply_checkbox_helper(2)

  def zoological_and_botanical_comply_checkbox_helper(self, position_comply_checkbox):
    """
    Helper for zoological_and_botanical_first_question_with_zoological_comply_accepted
    Helper for zoological_and_botanical_first_question_with_botanical_comply_accepted
    :param position_comply_checkbox: The position to extract the information needed for the _checkboxes
    """
    authors_comply_checkbox = self._gets(self._checkboxes)[position_comply_checkbox]
    authors_comply_checkbox.click()

  def zoological_and_botanical_first_question_checked_with_zoological_comply_accepted(self):
    """Validate zoological and botanical first question and both checked but only zoological comply accepted"""
    self.zoological_and_botanical_first_question_checked()
    self.zoological_and_botanical_comply_checkbox_helper(1)

  def zoological_and_botanical_first_question_checked_with_botanical_comply_accepted(self):
    """Validate zoological and botanical first question and both checked but only botanical comply accepted"""
    self.zoological_and_botanical_first_question_checked()
    self.zoological_and_botanical_comply_checkbox_helper(3)

  def zoological_and_botanical_first_question_checked(self):
    """
    Helper for zoological_and_botanical_first_question_checked_with_zoological_comply_accepted
    Helper for zoological_and_botanical_first_question_checked_with_botanical_comply_accepted
    Helper for zoological_and_botanical_with_all_checked
    """
    self.zoological_and_botanical_first_question_without_checkboxes()
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_checkbox, botanical_checkbox = self._gets(self._checkboxes)
    zoological_checkbox.click()
    botanical_checkbox.click()
    zoological_comply_text, botanical_comply_text = self._gets(self._comply_text)
    assert zoological_comply_text.text == (
        "Please read Regarding Submission of a new Taxon Name and indicate if you comply:"), \
        zoological_comply_text
    assert botanical_comply_text.text == (
        "Please read Regarding Submission of a new Taxon Name and indicate if you comply:"), \
        botanical_comply_text
    zoological_comply_link, botanical_comply_link = self._gets(self._comply_link)
    assert zoological_comply_link.get_attribute('href') == (
        'http://www.plosbiology.org/static/policies#taxon')
    assert botanical_comply_link.get_attribute('href') == (
        'http://www.plosbiology.org/static/policies#taxon')
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_authors_comply = self._gets(self._questions_text)[1]
    botanical_authors_comply = self._gets(self._questions_text)[3]
    assert zoological_authors_comply.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), \
        zoological_authors_comply
    assert botanical_authors_comply.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), \
        botanical_authors_comply

  def zoological_and_botanical_with_all_checked(self):
    """Validate zoological and botanical first question and both checked with comply accepted"""
    self.zoological_and_botanical_first_question_checked()
    self.zoological_and_botanical_comply_checkbox_helper(1)
    self.zoological_and_botanical_comply_checkbox_helper(3)

  def generate_random_taxon(self):
    import pdb; pdb.set_trace()
    radom_taxon = [self.zoological_and_botanical_first_question_without_checkboxes, \
                   self.zoological_and_botanical_first_question_with_one_checked, \
                   self.zoological_and_botanical_first_question_with_zoological_comply_accepted, \
                   self.zoological_and_botanical_first_question_with_botanical_comply_accepted, \
                   self.zoological_and_botanical_first_question_checked_with_zoological_comply_accepted, \
                   self.zoological_and_botanical_first_question_checked_with_botanical_comply_accepted, \
                   self.zoological_and_botanical_with_all_checked, \
                   self.zoological_and_botanical_first_question_checked
                  ]
    method = random.choice(radom_taxon)
    method()