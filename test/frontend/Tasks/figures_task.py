#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random
import time
from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Resources import figures
from frontend.Tasks.basetask import BaseTask

__author__ = 'jgray@plos.org'

class FiguresTask(BaseTask):
  """
  Page Object Model for Figures task
  """

  def __init__(self, driver, url_suffix='/'):
    super(FiguresTask, self).__init__(driver)

    #Locators - Instance members
    self._intro_text = (By.CSS_SELECTOR, 'div.task-main-content p')
    self._question_label = (By.CLASS_NAME, 'question-checkbox')
    self._question_check = (By.CLASS_NAME, 'ember-checkbox')
    self._add_new_figures_btn = (By.CLASS_NAME, 'button-primary')
    self._figures_list = (By.ID, 'figure-list')
    self._figure_listing = (By.CSS_SELECTOR, 'div.liquid-child > div.ember-view')
    self._figure_preview = (By.CSS_SELECTOR, 'img.image-thumbnail')
    self._figure_label = (By.CSS_SELECTOR, 'h2.title')
    self._figure_error_msg_a = (By.CSS_SELECTOR, 'div.info > h2 + div.error-message')
    self._figure_error_icon = (By.CSS_SELECTOR, 'i.fa-exclamation-triangle')
    self._figure_dl_link = (By.CSS_SELECTOR, 'div.download-link > a')
    self._figure_replace_btn = (By.CSS_SELECTOR, 'div.replace-file-button')
    self._figure_replace_input = (By.CSS_SELECTOR, 'input.ember-text-field')
    self._figure_error_msg_b = (By.CSS_SELECTOR,
                                'div.info > div.replace-file-button + div.error-message')
    self._figure_edit_icon = (By.CSS_SELECTOR, 'div.edit-icons > span.fa-pencil')
    self._figure_delete_icon = (By.CSS_SELECTOR, 'div.edit-icons > span.fa-trash')

  # POM Actions
  def validate_styles(self):
    """
    Validate styles in Figures Task
    """
    error_msg = ''
    intro_text = self._get(self._intro_text)
    # The intro paragraph is rendered in the incorrect font size
    # self.validate_application_ptext(intro_text)
    assert intro_text.text == (
        "Please confirm that your figures comply with our guidelines for preparation and "
        "have not been inappropriately manipulated. For information on image manipulation, "
        "please see our general guidance notes on image manipulation."
        ), intro_text.text
    assert self._get(self._question_label).text == 'Yes - I confirm our figures comply with the ' \
                                                   'guidelines.'
    self.validate_application_ptext(self._get(self._question_label))
    add_new_figures_btn = self._get(self._add_new_figures_btn)
    assert add_new_figures_btn.text == "ADD NEW FIGURES"
    self.validate_primary_big_green_button_style(add_new_figures_btn)
    self.set_timeout(5)
    # Trying moving this down to where it gets populated
    logging.info('Attempting to locate thumbnail')
    try:
      fig_listings = self._get(self._figures_list).find_elements(*self._figure_listing)
    except ElementDoesNotExistAssertionError:
      logging.info('Didn\'t find a figure thumbnail')
      return
    for fig_listing in fig_listings:
      self._get(self._figure_listing).find_element(*self._figure_preview)
      figure_label = self._get(self._figure_listing).find_element(*self._figure_label)
      if figure_label.text == 'Unlabeled':
        error_msg_b = self._get(self._figure_listing).find_element(*self._figure_error_msg_b)
        assert \
            "Sorry, we didn't find a figure label in this filename. Please edit to add a label." \
            in error_msg_b.text, error_msg_b.text
      else:
        try:
          error_msg = self._get(self._figure_listing).find_element(*self._figure_error_msg_a)
        except ElementDoesNotExistAssertionError:
          logging.info('No duplicate label error message displayed on figure listing')
      if error_msg:
        logging.warning(error_msg.text)
      self._get(self._figure_listing).find_element(*self._figure_error_icon)
      self._get(self._figure_listing).find_element(*self._figure_dl_link)
      self._get(self._figure_listing).find_element(*self._figure_replace_btn)
      self._get(self._figure_listing).find_element(*self._figure_replace_input)
      self._actions.move_to_element(fig_listing).perform()
      time.sleep(.5)
      edit_icon = self._get(self._figure_listing).find_element(*self._figure_edit_icon)
      self._actions.move_to_element(edit_icon).perform()
      time.sleep(.5)
      delete_icon = self._get(self._figure_listing).find_element(*self._figure_delete_icon)
      self._actions.move_to_element(delete_icon).perform()
      time.sleep(.5)
    self.restore_timeout()

  def check_question(self):
    """
    Click on the checkbox for the question:
    "Yes - I confirm our figures comply with the guidelines."
    :return: None
    """
    writable = not self.completed_state()
    if writable:
      self._get(self._question_check).click()
    else:
      self.click_completion_button()
      self._get(self._question_check).click()
      self.click_completion_button()

  def is_question_checked(self):
    """
    Checks if checkmark for the question on Figures task is applied or not
    :return: Bool
    """
    question_check= self._get(self._question_check)
    if question_check.is_selected():
      return True
    else:
      return False

  def upload_figure(self, figure2send='random', iterations=1):
    """
    Function to upload a figure file
    :param figure2send: Name of the figure to upload. If blank will default to 'random', this will
      choose one of available figures
    :param iterations: Number of files to upload. Defaults to 1.
    :return list of filename(s) of uploaded figure(s)
    """
    figure_candidates_list = figures
    chosen_figures_list = []
    for iteration in range(0, iterations):
      if figure2send == 'random':
        figure = random.choice(figure_candidates_list)
        fn = os.path.join(os.getcwd(), 'frontend/assets/imgs/{0}'.format(figure))
      else:
        figure = figure2send
        fn = os.path.join(os.getcwd(), 'frontend/assets/imgs/', figure)
      logging.info('Sending figure: {0}'.format(fn))
      time.sleep(1)
      self._driver.find_element_by_id('figure_attachment').send_keys(fn)
      add_new_figures_btn = self._get(self._add_new_figures_btn)
      add_new_figures_btn.click()
      figure_candidates_list.remove(figure)
      # Time needed for script execution.
      time.sleep(7)
      chosen_figures_list.append(figure)
    return chosen_figures_list

  def replace_figure(self, figure=''):
    """
    Function to replace and existing figure file
    :param figure: Name of the figure to replace.
    :return void function
    """
    if not figure:
      raise(ValueError, 'A figure was not specified')
    else:
      new_figure = random.choice(figures)
      fn = os.path.join(os.getcwd(), 'frontend/assets/imgs/{0}'.format(new_figure))
    logging.info('Replacing figure: {0}, with {1}'.format(figure, new_figure))
    time.sleep(1)
    replace_input = self._get(self._figure_listing).find_element(*self._figure_replace_input)
    replace_btn = self._get(self._figure_listing).find_element(*self._figure_replace_btn)
    replace_input.send_keys(fn)
    replace_btn.click()
    # Time needed for script execution.
    time.sleep(7)

