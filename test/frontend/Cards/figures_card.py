#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class FiguresCard(BaseCard):
  """
  Page Object Model for Figures Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(FiguresCard, self).__init__(driver)

    #Locators - Instance members
    self._card_title = (By.TAG_NAME, 'h1')
    self._intro_text = (By.TAG_NAME, 'p')
    self._question_label = (By.CLASS_NAME, 'question-checkbox')
    self._question_check = (By.CLASS_NAME, 'ember-checkbox')
    self._add_new_figures_btn = (By.CLASS_NAME, 'button-primary')
    self._populated_figure_listing = (By.CLASS_NAME, 'attachment-thumbnail')
    self._populated_figure_preview = (By.CLASS_NAME, 'image-thumbnail')
    self._populated_figure_view_detail = (By.CSS_SELECTOR,
                                          'div.image-hover-buttons button.view-attachment-detail')
    self._populated_figure_replace = (By.CSS_SELECTOR, 'div.image-hover-buttons button.replace')
    self._populated_figure_dl_link = (By.CLASS_NAME, 'download-link')
    self._populated_figure_view_title = (By.CSS_SELECTOR, 'h2.title')
    self._populated_figure_edit_icon = (By.CSS_SELECTOR, 'div.edit-icons > span.fa-pencil')
    self._populated_figure_delete_icon = (By.CSS_SELECTOR, 'div.edit-icons > span.fa-trash')


   #POM Actions

  def validate_styles(self):
    """
    Validate styles in Figures Card
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

