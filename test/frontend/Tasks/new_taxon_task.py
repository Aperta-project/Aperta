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
    self._questions = (By.CSS_SELECTOR, '.question > div')
    self._comply_text = (By.XPATH, 
                        "//*[contains(@id, 'ember')]//*[contains(@class, 'additional-data')]//*[contains(@class, 'question-text')]/p")
    self._comply_link = (By.XPATH, 
                        "//*[contains(@id, 'ember')]//*[contains(@class, 'additional-data')]//*[contains(@class, 'question-text')]/p/a")
    self._questions_text = (By.CLASS_NAME, 'model-question')
    self._checkboxes = (By.XPATH, "//*[@class='question-checkbox']/input")

  # POM Actions
  def generate_test_scenario(self, total_questions):
    """This method generate a random scenario for the New Taxon Task"""
    scenario = []

    for i in range(total_questions):
      question_scenario = {}
      question_scenario['checkbox'] = bool(random.getrandbits(1))
      if question_scenario['checkbox']:
        question_scenario['compliance'] = bool(random.getrandbits(1))
      else:
        question_scenario['compliance'] = False
      scenario.append(question_scenario)
    return scenario

  def validate_taxon_questions_action(self, scenario):
    """This method validate the given scenario and click the corresponding checkboxes in the Task"""
    time.sleep(3)
    items = self._gets(self._questions)

    for key, item in enumerate(items):
      question_scenario = scenario[key]
      question = item.find_element_by_class_name('question-checkbox')
      checkbox = question.find_element_by_tag_name('input')
      text = question.find_element_by_class_name('model-question')
      
      if key == 0:
        assert text.text == (
        "Does this manuscript describe a new zoological taxon name?"), text
      elif key == 1:
        assert text.text == (
        "Does this manuscript describe a new botanical taxon name?"), text

      if question_scenario['checkbox']:
        checkbox.click()
        additional_data = item.find_element_by_class_name('additional-data')
        compliance_checkbox = additional_data.find_element_by_tag_name('input')
        comply_text = self._gets(self._comply_text)[0]
        comply_link = self._gets(self._comply_link)[0]
        authors_text = additional_data.find_element_by_class_name('model-question')

        assert comply_text.text == (
        "Please read Regarding Submission of a new Taxon Name and indicate if you comply:"), \
        comply_text
        assert authors_text.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), \
        authors_comply
        assert comply_link.get_attribute('href') == (
        'http://www.plosbiology.org/static/policies#taxon')
        
        if question_scenario['compliance']:
          compliance_checkbox.click()

  def validate_task_elements_styles(self):
    self.validate_common_elements_styles()
    map(self.validate_checkbox, self._gets(self._checkboxes))
    map(self.validate_textarea_style, self._gets(self._questions_text))
    map(self.validate_textarea_style, self._gets(self._comply_text))
    map(self.validate_default_link_style, self._gets(self._comply_link))