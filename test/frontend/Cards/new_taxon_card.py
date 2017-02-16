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
    self._comply_text = (By.XPATH, 
                        "//*[contains(@id, 'ember')]//*[contains(@class, 'additional-data')]//*[contains(@class, 'question-text')]/p")
    self._comply_link = (By.XPATH, 
                        "//*[contains(@id, 'ember')]//*[contains(@class, 'additional-data')]//*[contains(@class, 'question-text')]/p/a")

  def validate_card_elements_styles(self, paper_id):
    """
    This method validates the styles of the card elements including the common card elements
    :return void function
    """
    self.validate_common_elements_styles(paper_id)

  # POM Actions
  def validate_taxon_questions_answers(self, scenario):
    """Validate the Card view and compare if the selected data on Task is the same"""
    items = self._gets((By.CSS_SELECTOR, '.question > div'))
    
    for key, item in enumerate(items):
      question_scenario = scenario[key]
      question = item.find_element_by_class_name('question-checkbox')
      checkbox = question.find_element_by_tag_name('input')
      text = question.find_element_by_class_name('model-question')
      
      assert checkbox.is_selected() == question_scenario['checkbox'], \
          'The question {0} checkbox state: {1} is not the expected: {2}'.format(key, \
           str(checkbox.is_selected()), str(question_scenario['checkbox']))

      if key == 0:
        assert text.text == (
        "Does this manuscript describe a new zoological taxon name?"), text
      elif key == 1:
        assert text.text == (
        "Does this manuscript describe a new botanical taxon name?"), text
           
      if question_scenario['checkbox']:
        additional_data = item.find_element_by_class_name('additional-data')
        compliance_checkbox = additional_data.find_element_by_tag_name('input')
        comply_text = self._gets(self._comply_text)[0]
        comply_link = self._gets(self._comply_link)[0]
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