#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

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

  # POM Actions
  def generate_test_scenario(self):
    """
    This method generate a random scenario for the New Taxon Task
    :return: A list with boolean elements
    """
    scenario = []
    TOTAL_QUESTIONS = 2

    for i in range(TOTAL_QUESTIONS):
      question_scenario = {}
      question_scenario['checkbox'] = self.get_random_bool()
      if question_scenario['checkbox']:
        question_scenario['compliance'] = self.get_random_bool()
      else:
        question_scenario['compliance'] = False
      scenario.append(question_scenario)

    return scenario

  def validate_taxon_questions_action(self, scenario):
    """
    This method validate the given scenario and click the corresponding checkboxes in the Task
    :param scenario: Is the scenario needed to fill the Task
    :return: None
    """
    # Time needed after clicking on New Taxon Task for elements to be ready
    time.sleep(3)
    items = self._gets(self._questions)

    for key, item in enumerate(items):
      question_scenario = scenario[key]
      question = item.find_element_by_class_name('question-checkbox')
      checkbox = question.find_element_by_tag_name('input')

      if question_scenario['checkbox']:
        checkbox.click()
        additional_data = item.find_element_by_class_name('additional-data')
        compliance_checkbox = additional_data.find_element_by_tag_name('input')
        
        if question_scenario['compliance']:
          compliance_checkbox.click()
    #Time needed for the system to save all the selected checkboxes
    time.sleep(3)

  def validate_task_elements(self, scenario):
    """
    Validate the elements and styles of the Task
    :param scenario: Is the scenario needed to extract the elements
    :return: None
    """
    items = self._gets(self._questions)

    for key, item in enumerate(items):
      question_scenario = scenario[key]
      question = item.find_element_by_class_name('question-checkbox')
      checkbox = question.find_element_by_tag_name('input')
      text = question.find_element_by_class_name('model-question')
      
      text_list = ["Does this manuscript describe a new %s taxon name?" % types \
          for types in ["zoological", "botanical"]]
      assert text.text == text_list[key], text

      if question_scenario['checkbox']:
        additional_data = item.find_element_by_class_name('additional-data')
        compliance_checkbox = additional_data.find_element_by_tag_name('input')
        comply_text = additional_data.find_element_by_tag_name('p')
        comply_link = additional_data.find_element_by_css_selector('p a')
        authors_text = additional_data.find_element_by_class_name('model-question')
        assert comply_text.text == (
        "Please read Regarding Submission of a new Taxon Name and indicate if you comply:"), \
        comply_text
        assert authors_text.text == (
        "All authors comply with the Policies Regarding Submission of a new Taxon Name"), \
        authors_comply
        assert comply_link.get_attribute('href') == \
            'http://www.plosbiology.org/static/policies#taxon', comply_link.get_attribute('href')
        self.validate_task_styles(checkbox, text, 
                                           compliance_checkbox, comply_link, 
                                           comply_text, authors_text
                                          )

  def validate_task_styles(self, checkbox, text, compliance_checkbox, comply_link, comply_text,
                           authors_text):
    """
    Validate the elements styles for New Taxon Task
    :param checkbox: The selected checkbox
    :param text: The text for questions
    :param compliance_checkbox: The compliance checkbox
    :param comply_link: The link for the comply text
    :param comply_text: The comply text
    :param authors_text: The authors comply text
    :return: None
    """
    self.validate_common_elements_styles()
    self.validate_checkbox(checkbox)
    self.validate_default_link_style(comply_link)
    map(self.validate_textarea_style, [text, comply_text, authors_text])