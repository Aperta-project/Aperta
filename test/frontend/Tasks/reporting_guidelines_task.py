#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import logging
import os
import random

from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask

__author__ = 'achoe@plos.org'

class ReportingGuidelinesTask(BaseTask):
  """
  Page Object for the Reporting Guidelines task
  """

  def __init__(self, driver):
    super(ReportingGuidelinesTask, self).__init__(driver)

    # Locators - Instance members
    self._question_text = (By.CLASS_NAME, 'question-text')
    self._select_instruction = (By.CLASS_NAME, 'help')
    self._selection_list = (By.CLASS_NAME, 'list-unstyled')

  # POM Actions
  def validate_styles(self):
    """
    Validates styles in the Reporting Guidelines Task
    """
    question_text = self._get(self._question_text)
    assert question_text.text == 'Authors should check the EQUATOR Network site for any reporting' \
                                 ' guidelines that apply to their study design, and ensure that any' \
                                 ' required Supporting Information (checklists, protocols, flowcharts,' \
                                 ' etc.) be included in the article submission.'
    select_instruction = self._get(self._select_instruction)
    self.validate_application_ptext(select_instruction)
    selection_list = self._get(self._selection_list)
    self.validate_application_ptext(selection_list)
    selection_list_items = selection_list.find_elements_by_css_selector('li.item')
    # All checkboxes should be unchecked by default:
    for item in selection_list_items:
      assert item.find_element_by_tag_name('input').is_selected() is False, 'Item {0} is ' \
                                                                            'checked by default'.format(item.text)
    self.validate_common_elements_styles()
