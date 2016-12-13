#!/usr/bin/env python2
# -*- coding: utf-8 -*-

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

  # POM Actions

  def validate_styles(self):
    """
    Validate styles in Reporting Guidelines card
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
      assert item.find_element_by_tag_name('input').is_selected() is False, 'Item {0} is ' \
                                                                            'checked by default'.format(item.text)

