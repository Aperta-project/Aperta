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
    return [False,False,False,False]

  def zoological_and_botanical_first_question_with_zoological_checked(self):
    """Validate zoological and botanical first question with zoological checked"""
    self.zoological_and_botanical_first_question_with_one_checked_helper(0,1)
    return [True,False,False,False]
  
  def zoological_and_botanical_first_question_with_botanical_checked(self):
    """Validate zoological and botanical first question with botanical checked"""
    self.zoological_and_botanical_first_question_with_one_checked_helper(1,2)
    return [False,False,True,False]

  def zoological_and_botanical_first_question_with_one_checked_helper(self, 
                                                                      position_checkbox,
                                                                      position_text):
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
    comply_text = self._get(self._comply_text)
    assert comply_text.text == (
        "Please read Regarding Submission of a new Taxon Name and indicate if you comply:"), \
        comply_text
    comply_link = self._get(self._comply_link)
    assert comply_link.get_attribute('href') == 'http://www.plosbiology.org/static/policies#taxon'
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    authors_comply = self._gets(self._questions_text)[position_text]
    assert authors_comply.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), \
        authors_comply

  def zoological_and_botanical_first_question_with_zoological_comply_accepted(self):
    """Validate zoological and botanical first question with zoological checked and comply accepted"""
    self.zoological_and_botanical_first_question_with_one_checked_helper(0,1)
    self.zoological_and_botanical_comply_checkbox_helper(1)
    return [True,True,False,False]

  def zoological_and_botanical_first_question_with_botanical_comply_accepted(self):
    """Validate zoological and botanical first question with botanical checked and comply accepted"""
    self.zoological_and_botanical_first_question_with_one_checked_helper(1,2)
    self.zoological_and_botanical_comply_checkbox_helper(2)
    return [False,False,True,True]

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
    self.zoological_and_botanical_first_question_checked_helper()
    self.zoological_and_botanical_comply_checkbox_helper(1)
    return [True,True,True,False]

  def zoological_and_botanical_first_question_checked_with_botanical_comply_accepted(self):
    """Validate zoological and botanical first question and both checked but only botanical comply accepted"""
    self.zoological_and_botanical_first_question_checked_helper()
    self.zoological_and_botanical_comply_checkbox_helper(3)
    return [True,False,True,True]

  def zoological_and_botanical_first_question_checked_helper(self):
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
    self.zoological_and_botanical_first_question_checked_helper()
    self.zoological_and_botanical_comply_checkbox_helper(1)
    self.zoological_and_botanical_comply_checkbox_helper(3)
    return [True,True,True,True]

  def generate_random_taxon(self):
    random_taxon = [self.zoological_and_botanical_first_question_without_checkboxes, \
                   self.zoological_and_botanical_first_question_with_zoological_checked, \
                   self.zoological_and_botanical_first_question_with_botanical_checked, \
                   self.zoological_and_botanical_first_question_with_zoological_comply_accepted, \
                   self.zoological_and_botanical_first_question_with_botanical_comply_accepted, \
                   self.zoological_and_botanical_first_question_checked_with_zoological_comply_accepted, \
                   self.zoological_and_botanical_first_question_checked_with_botanical_comply_accepted, \
                   self.zoological_and_botanical_with_all_checked
                  ]
    method = random.choice(random_taxon)
    data = method()
    return data

  def data_validation(self, data):
    """Validation of the data to log into the logging.info()"""
    if data == [False,False,False,False]:
      outdata = self.zoological_and_botanical_first_question_without_checkboxes()
    elif data == [True,False,False,False]:
      outdata = self.zoological_and_botanical_first_question_with_zoological_checked()
    elif data == [False,False,True,False]:
      outdata = self.zoological_and_botanical_first_question_with_botanical_checked()
    elif data == [True,True,False,False]:
      outdata = self.zoological_and_botanical_first_question_with_zoological_comply_accepted()
    elif data == [False,False,True,True]:
      outdata = self.zoological_and_botanical_first_question_with_botanical_comply_accepted()
    elif data == [True,True,True,False]:
      outdata = \
      self.zoological_and_botanical_first_question_checked_with_zoological_comply_accepted()
    elif data == [True,False,True,True]:
      outdata = \
      self.zoological_and_botanical_first_question_checked_with_botanical_comply_accepted()
    elif data == [True,True,True,True]:
      outdata = self.zoological_and_botanical_with_all_checked()
    return outdata