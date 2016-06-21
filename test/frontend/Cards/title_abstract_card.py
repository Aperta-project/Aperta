#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'jgray@plos.org'

class TitleAbstractCard(BaseCard):
  """
  Page Object Model for the Title and Abstract Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(TitleAbstractCard, self).__init__(driver)

    #Locators - Instance members
    self._title_label = (By.CSS_SELECTOR, 'div.title-and-abstract > div.form-group > h3')
    self._title_textarea = (By.CSS_SELECTOR,
                            'div.title-and-abstract > div.form-group > div.form-textarea')
    self._abstract_label = (By. CSS_SELECTOR,
                            'div.title-and-abstract > div.form-group + div.form-group > h3')
    self._abstract_textarea = (
        By.CSS_SELECTOR,
        'div.title-and-abstract > div.form-group + div.form-group > div.form-textarea')

    #POM Actions

  def validate_styles(self):
    """
    Validate styles in the Title and Abstract Card
    """

    card_title = self._get(self._card_title)
    assert card_title.text == 'Figures'
    self.validate_application_title_style(card_title)
    intro_text = self._get(self._intro_text)
    self.validate_application_ptext(intro_text)
    assert intro_text.text == (
      "Please confirm that your figures comply with our guidelines for preparation and "
      "have not been inappropriately manipulated. For information on image manipulation, "
      "please see our general guidance notes on image manipulation."
      ), intro_text.text
    assert self._get(self._question_label).text == "Yes - I confirm our figures comply with the guidelines."
    self.validate_application_ptext(self._get(self._question_label))
    add_new_figures_btn = self._get(self._add_new_figures_btn)
    add_new_figures_btn.text == "ADD NEW FIGURES"
    self.validate_primary_big_green_button_style(add_new_figures_btn)

  def check_question(self):
    """
    Click on the checkmark for the question:
    "Yes - I confirm our figures comply with the guidelines."
    :return: None
    """
    self._get(self._question_check).click()
    time.sleep(.5)

  def is_question_checked(self):
    """
    Checks if checkmark for the question on Image card is applied or not
    :return: Bool
    """
    question_check= self._get(self._question_check)
    if question_check.is_selected():
      return True
    else:
      return False

  def upload_figure(self, file_path):
    """
    Placeholder for a function to upload a tiff file in the Figures Card
    """
    pass
