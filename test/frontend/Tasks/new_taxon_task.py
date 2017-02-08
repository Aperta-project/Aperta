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
  def validate_all_new_taxon_task_styles(self):
    """Validate both zoological and botanical options"""
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_text, botanical_text = self._gets(self._questions_text)
    assert zoological_text.text == "Does this manuscript describe a new zoological taxon name?", \
        zoological_text
    assert botanical_text.text == "Does this manuscript describe a new botanical taxon name?", \
        botanical_text
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
    zoological_authors_comply_checkbox = self._gets(self._checkboxes)[1]
    botanical_authors_comply_checkbox = self._gets(self._checkboxes)[3]
    zoological_authors_comply_checkbox.click()
    botanical_authors_comply_checkbox.click()

  def validate_zoological_taxon_with_comply_style(self):
    """Validate only zoological option"""
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_text = self._gets(self._questions_text)[0]
    assert zoological_text.text == "Does this manuscript describe a new zoological taxon name?", \
        zoological_text
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_checkbox = self._gets(self._checkboxes)[0]
    zoological_checkbox.click()
    zoological_comply_text = self._gets(self._comply_text)[0]
    assert zoological_comply_text.text == (
        "Please read Regarding Submission of a new Taxon Name and indicate if you comply:"), \
        zoological_comply_text
    zoological_comply_link = self._gets(self._comply_link)[0]
    assert zoological_comply_link.get_attribute('href') == (
        'http://www.plosbiology.org/static/policies#taxon')
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_authors_comply = self._gets(self._questions_text)[1]
    assert zoological_authors_comply.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), \
        zoological_authors_comply
    zoological_authors_comply_checkbox = self._gets(self._checkboxes)[1]
    zoological_authors_comply_checkbox.click()
    
  def validate_botanical_taxon_with_comply_style(self):
    """Validate only botanical option"""
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    botanical_text = self._gets(self._questions_text)[1]
    assert botanical_text.text == "Does this manuscript describe a new botanical taxon name?", \
        botanical_text
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    botanical_checkbox = self._gets(self._checkboxes)[1]
    botanical_checkbox.click()
    botanical_comply_text = self._gets(self._comply_text)[0]
    assert botanical_comply_text.text == (
        "Please read Regarding Submission of a new Taxon Name and indicate if you comply:"), \
        botanical_comply_text
    botanical_comply_link = self._gets(self._comply_link)[0]
    assert botanical_comply_link.get_attribute('href') == (
        'http://www.plosbiology.org/static/policies#taxon')
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    botanical_authors_comply = self._gets(self._questions_text)[2]
    assert botanical_authors_comply.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), \
        botanical_authors_comply
    botanical_authors_comply_checkbox = self._gets(self._checkboxes)[2]
    botanical_authors_comply_checkbox.click()

  def validate_zoological_taxon_style(self):
    """Validate only zoological option"""
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_text = self._gets(self._questions_text)[0]
    assert zoological_text.text == "Does this manuscript describe a new zoological taxon name?", \
        zoological_text
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_checkbox = self._gets(self._checkboxes)[0]
    zoological_checkbox.click()
    zoological_comply_text = self._gets(self._comply_text)[0]
    assert zoological_comply_text.text == (
        "Please read Regarding Submission of a new Taxon Name and indicate if you comply:"), \
        zoological_comply_text
    zoological_comply_link = self._gets(self._comply_link)[0]
    assert zoological_comply_link.get_attribute('href') == (
        'http://www.plosbiology.org/static/policies#taxon')
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_authors_comply = self._gets(self._questions_text)[1]
    assert zoological_authors_comply.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), \
        zoological_authors_comply

  def validate_botanical_taxon_style(self):
    """Validate only botanical option"""
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    botanical_text = self._gets(self._questions_text)[1]
    assert botanical_text.text == "Does this manuscript describe a new botanical taxon name?", \
        botanical_text
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    botanical_checkbox = self._gets(self._checkboxes)[1]
    botanical_checkbox.click()
    botanical_comply_text = self._gets(self._comply_text)[0]
    assert botanical_comply_text.text == (
        "Please read Regarding Submission of a new Taxon Name and indicate if you comply:"), \
        botanical_comply_text
    botanical_comply_link = self._gets(self._comply_link)[0]
    assert botanical_comply_link.get_attribute('href') == (
        'http://www.plosbiology.org/static/policies#taxon')
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    botanical_authors_comply = self._gets(self._questions_text)[2]
    assert botanical_authors_comply.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), \
        botanical_authors_comply

  def validate_zoological_and_botanical_taxon_styles(self):
    """Validate both zoological and botanical options"""
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_text, botanical_text = self._gets(self._questions_text)
    assert zoological_text.text == "Does this manuscript describe a new zoological taxon name?", \
        zoological_text
    assert botanical_text.text == "Does this manuscript describe a new botanical taxon name?", \
        botanical_text
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

  def validate_zoological_with_comply_and_botanical_style(self):
    """Validate both zoological and botanical options"""
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_text, botanical_text = self._gets(self._questions_text)
    assert zoological_text.text == "Does this manuscript describe a new zoological taxon name?", \
        zoological_text
    assert botanical_text.text == "Does this manuscript describe a new botanical taxon name?", \
        botanical_text
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
    zoological_authors_comply_checkbox = self._gets(self._checkboxes)[1]
    zoological_authors_comply_checkbox.click()

  def validate_zoological_and_botanical_with_comply_style(self):
    """Validate both zoological and botanical options"""
    # Time needed for some elements to be loaded into the DOM
    time.sleep(2)
    zoological_text, botanical_text = self._gets(self._questions_text)
    assert zoological_text.text == "Does this manuscript describe a new zoological taxon name?", \
        zoological_text
    assert botanical_text.text == "Does this manuscript describe a new botanical taxon name?", \
        botanical_text
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
    botanical_authors_comply_checkbox = self._gets(self._checkboxes)[3]
    botanical_authors_comply_checkbox.click()

  def generate_random_taxon(self):
    radom_taxon = [self.validate_zoological_taxon_style, \
                   self.validate_botanical_taxon_style, \
                   self.validate_zoological_taxon_with_comply_style, \
                   self.validate_botanical_taxon_with_comply_style, \
                   self.validate_all_new_taxon_task_styles, \
                   self.validate_zoological_and_botanical_taxon_styles, \
                   self.validate_zoological_and_botanical_with_comply_style, \
                   self.validate_zoological_with_comply_and_botanical_style
                  ]
    method = random.choice(radom_taxon)
    method()