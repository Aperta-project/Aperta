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
    self._questions = (By.CSS_SELECTOR, '.question > div')

  # POM Actions
  def validate_taxon_questions_answers(self, scenario):
    """
    Validate the Card view and compare if the selected data on Task is the same
    :param scenario: Is the scenario selected in the Task
    """
    items = self._gets((By.CSS_SELECTOR, '.question > div'))
    
    for key, item in enumerate(items):
      question_scenario = scenario[key]
      question = item.find_element_by_class_name('question-checkbox')
      checkbox = question.find_element_by_tag_name('input')
      
      assert checkbox.is_selected() == question_scenario['checkbox'], \
          'The question {0} checkbox state: {1} is not the expected: {2}'.format(key, \
           str(checkbox.is_selected()), str(question_scenario['checkbox']))
           
      if question_scenario['checkbox']:
        additional_data = item.find_element_by_class_name('additional-data')
        compliance_checkbox = additional_data.find_element_by_tag_name('input')

        assert compliance_checkbox.is_selected() == question_scenario['compliance'], \
            'The question {0} checkbox state: {1} is not the expected: {2}'.format(key, \
            str(compliance_checkbox.is_selected()), str(question_scenario['compliance']))

  def validate_card_elements_styles(self, paper_id, scenario):
    """
    This method validates the styles of the card elements including the common card elements
    :param paper_id: The id of the manuscript
    :param scenario: Is the scenario selected in the Task
    """
    self.validate_common_elements_styles(paper_id)
    
    items = self._gets((By.CSS_SELECTOR, '.question > div'))
    
    for key, item in enumerate(items):
      question_scenario = scenario[key]
      question = item.find_element_by_class_name('question-checkbox')
      checkbox = question.find_element_by_tag_name('input')
      text = question.find_element_by_class_name('model-question')
      
      assert checkbox.is_selected() == question_scenario['checkbox'], \
          'The question {0} checkbox state: {1} is not the expected: {2}'.format(key, \
          str(checkbox.is_selected()), str(question_scenario['checkbox']))
          
      text_list = ["Does this manuscript describe a new %s taxon name?" % types \
          for types in ["zoological", "botanical"]]
      assert text.text == text_list[key], text
      
      if question_scenario['checkbox']:
        additional_data = item.find_element_by_class_name('additional-data')
        compliance_checkbox = additional_data.find_element_by_tag_name('input')
        comply_text = additional_data.find_element_by_tag_name('p')
        comply_link = additional_data.find_element_by_css_selector('p a')
        authors_text = additional_data.find_element_by_class_name('model-question')
        
        assert compliance_checkbox.is_selected() == question_scenario['compliance'], \
            'The question {0} checkbox state: {1} is not the expected: {2}'.format(key, \
            str(compliance_checkbox.is_selected()), str(question_scenario['compliance']))
        assert comply_text.text == (
            "Please read Regarding Submission of a new Taxon Name and indicate if you comply:"), \
            comply_text
        assert authors_text.text == (
            "All authors comply with the Policies Regarding Submission of a new Taxon Name"), \
            authors_comply
        assert comply_link.get_attribute('href') == (
            'http://www.plosbiology.org/static/policies#taxon')

        self.validate_card_elements_styles(checkbox, text, 
                                           compliance_checkbox, comply_link, 
                                           comply_text, authors_text
                                          )

  def validate_card_elements_styles(self, checkbox, text, 
                                    compliance_checkbox, comply_link, comply_text, authors_text):
    """
    Validate the elements styles for New Taxon Card
    :param checkbox: The selected checkbox
    :param text: The text for questions
    :param compliance_checkbox: The compliance checkbox
    :param comply_link: The link for the comply text
    :param comply_text: The comply text
    :param authors_text: The authors comply text
    """
    self.validate_common_elements_styles()
    self.validate_checkbox(checkbox)
    self.validate_default_link_style(comply_link)
    map(self.validate_textarea_style, [text, comply_text, authors_text])