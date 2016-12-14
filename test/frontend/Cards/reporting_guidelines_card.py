#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import logging

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'achoe@plos.org'


class ReportingGuidelinesCard(BaseCard):
  """
  Page Object Model for the Reporting Guidelines Card
  """

  def __init__(self, driver):
    super(ReportingGuidelinesCard, self).__init__(driver)

    # Locators - instance members
    self._question_text = (By.CLASS_NAME, 'question-text')
    self._select_instruction = (By.CLASS_NAME, 'help')
    self._selection_list = (By.CLASS_NAME, 'list-unstyled')
    self._prisma_uploaded_file_link = (By.CLASS_NAME, 'file-link')

  # POM Actions

  def validate_styles(self):
    """
    Validate styles in Reporting Guidelines card
    :return: None
    """
    completed = self.completed_state()
    if completed:
      self.click_completion_button()
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Reporting Guidelines', card_title.text
    self.validate_application_title_style(card_title)
    question_text = self._get(self._question_text)
    assert question_text.text == 'Authors should check the EQUATOR Network site for any reporting' \
                             ' guidelines that apply to their study design, and ensure that any' \
                             ' required Supporting Information (checklists, protocols, flowcharts,' \
                             ' etc.) be included in the article submission.', question_text.text
    select_instruction = self._get(self._select_instruction)
    self.validate_application_ptext(select_instruction)
    selection_list = self._get(self._selection_list)
    self.validate_application_ptext(selection_list)
    selection_list_items = selection_list.find_elements_by_css_selector('li.item')
    # All checkboxes should be unchecked by default:
    for item in selection_list_items:
      list_item = item.find_element_by_tag_name('input')
      assert not list_item.is_selected, 'Item {0} is checked by default'.format(item.text)

  def check_selections(self, choices, filename=None):
    """
    Validates that the selections in the card view match the selections from the task view
    :param choices: The list of indices of the checkboxes that were selected in the task view
    :param filename: The file name for the uploaded PRISMA checklist, if any
    (e.g. frontend/assets/PRISMA_2009_checklist.doc)
    :return: None
    """
    selection_list = self._get(self._selection_list)
    list_items = selection_list.find_elements_by_css_selector('li.item')
    for choice in choices:
      logging.info('Checking these selections: {0}'.format(list_items[choice].text))
      selected = list_items[choice].find_element_by_tag_name('input').is_selected()
      assert selected is True, '{0} is checked on Reporting Guidelines task, but not' \
                               ' on the card'.format(list_items[choice].text)

    if filename:
      uploaded_prisma_file = self._get(self._prisma_uploaded_file_link)
      assert filename.split('/')[-1] == uploaded_prisma_file.text, 'Uploaded file {0} is ' \
                                                                   'not displayed in the Reporting Guidelines ' \
                                                                   'card'.format(filename.split('/')[-1])



