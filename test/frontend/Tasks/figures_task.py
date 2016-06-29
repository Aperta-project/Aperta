#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random
import time
import urllib

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
    self._figure_delete_confirmation = (By.CSS_SELECTOR, 'div.delete-confirmation')
    self._figure_delete_confirm_line1 = (By.CSS_SELECTOR, 'div.delete-confirmation > h4')
    self._figure_delete_confirm_line2 = (By.CSS_SELECTOR, 'div.delete-confirmation > h4 + h4')
    self._figure_delete_confirm_cancel = (By.CSS_SELECTOR, 'div.delete-confirmation > a')
    self._figure_delete_confirm_confirm = (By.CSS_SELECTOR, 'div.delete-confirmation > button')

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
      # Time needed for script execution per photo for upload, storing, preview generation, and
      #   page update
      time.sleep(25)
      chosen_figures_list.append(figure)
      self.check_for_flash_error()
    return chosen_figures_list

  def replace_figure(self, figure=''):
    """
    Function to replace and existing figure file
    :param figure: Name of the figure to replace.
    :return a list containing the filename of the new figure
    """
    if not figure:
      raise(ValueError, 'A figure was not specified')
    else:
      new_figure = random.choice(figures)
      fn = os.path.join(os.getcwd(), 'frontend/assets/imgs/{0}'.format(new_figure))
    logging.info('Replacing figure: {0}, with {1}'.format(figure, new_figure))
    time.sleep(5)
    # Redefining this down here to avoid a stale element reference due to the listing having been
    #   replaced, potentially, since lookup
    self._figure_listing = (By.CSS_SELECTOR, 'div.liquid-child > div.ember-view')
    replace_input = self._get(self._figure_listing).find_element(*self._figure_replace_input)
    replace_btn = self._get(self._figure_listing).find_element(*self._figure_replace_btn)
    replace_input.send_keys(fn)
    replace_btn.click()
    # Time needed for script execution. Have had intermittent failures at 25s delay, leads to a
    #   stale reference error
    time.sleep(30)
    fig_list = []
    fig_list.append(new_figure)
    return fig_list

  def delete_figure(self, figure=''):
    """
    Function to delete the named figure file, also validates the styles of the delete components
    :param figure: Name of the figure to delete.
    :return void function
    """
    if not figure:
      raise(ValueError, 'A figure must be specified')
    logging.info(figure)

    page_fig_list = self._gets(self._figure_dl_link)
    figure = urllib.quote_plus(figure[0])
    for page_fig_item in page_fig_list:
      if figure == page_fig_item.text:
        logging.info('Deleting figure: {0}'.format(figure))
        time.sleep(5)
        # Redefining this down here to avoid a stale element reference due to the listing having
        #   been replaced, potentially, since lookup
        self._figure_listing = (By.CSS_SELECTOR, 'div.liquid-child > div.ember-view')
        # Move to item to get the edit icons to appear
        self._actions.move_to_element(page_fig_item).perform()
        delete_icon = self._get(self._figure_delete_icon)
        delete_icon.click()
        time.sleep(1)
        self._get(self._figure_delete_confirmation)
        line_1 = self._get(self._figure_delete_confirm_line1)
        assert 'This will permanently delete this file.' in line_1.text, line_1.text
        line_2 = self._get(self._figure_delete_confirm_line2)
        assert 'Are you sure?' in line_2.text, line_2.text
        cancel_link = self._get(self._figure_delete_confirm_cancel)
        assert 'cancel' in cancel_link.text
        cancel_link.click()
        delete_icon.click()
        time.sleep(1)
        delete_btn = self._get(self._figure_delete_confirm_confirm)
        assert 'DELETE FOREVER' in delete_btn.text, delete_btn.text
        delete_btn.click()
        time.sleep(5)
        return
      logging.info('no match found')

  def download_figure(self, figure=''):
    """
    Function to download an existing figure file
    :param figure: Name of the figure to download.
    :return void function
    """
    matched = False
    if not figure:
      raise (ValueError, 'A figure was not specified')
    logging.info('Downloading figure: {0}'.format(figure))
    time.sleep(5)
    page_fig_list = self._gets(self._figure_dl_link)
    for page_fig_item in page_fig_list:
      for fig in figure:
        fig = urllib.quote_plus(fig)
        if fig in page_fig_item.text:
          logging.info('Match!')
          page_fig_item.click()
          time.sleep(1)
          os.chdir('/tmp')
          files = filter(os.path.isfile, os.listdir('/tmp'))
          files = [os.path.join('/tmp', f) for f in files]  # add path to each file
          files.sort(key=lambda x: os.path.getmtime(x))
          newest_file = files[-1]
          logging.debug(newest_file)
          while newest_file.split('.')[-1] == 'part':
            time.sleep(5)
            files = filter(os.path.isfile, os.listdir('/tmp'))
            files = [os.path.join('/tmp', f) for f in files]  # add path to each file
            files.sort(key=lambda x: os.path.getmtime(x))
            newest_file = files[-1]
            logging.debug(newest_file.split('.')[-1])
          newest_file = newest_file.split('/')[-1]
          assert fig == newest_file, newest_file
          os.remove(newest_file)
          return
    if not matched:
      raise(ElementDoesNotExistAssertionError, 'No match found for {0}'.format(figure))

  def validate_figure_presence(self, fig_list):
    """
    Given a list of figures (file titles), validated they are all present on the Figures task
    :param fig_list: list of file names
    :return: boolean, true if all passed filenames appear on the figures card
    """
    page_fig_list = self._gets(self._figure_dl_link)
    page_fig_name_list = []
    for page_fig_item in page_fig_list:
      page_fig_name_list.append(page_fig_item.text)
    logging.info('Figures from the page: {0}'.format(page_fig_name_list))
    for figure in fig_list:
      # We shouldn't have to url-encode this, but due to APERTA-6946 we must for now.
      assert urllib.quote_plus(figure) in page_fig_name_list, \
          '{0} not found in {1}'.format(urllib.quote_plus(figure), page_fig_name_list)

  def validate_figure_not_present(self, fig_list):
    """
    Given a list of figures (file titles), validated they are not present on the Figures task
    :param fig_list: list of file names
    :return: void function
    """
    page_fig_name_list = []
    page_fig_list = self._gets(self._figure_dl_link)
    for page_fig_item in page_fig_list:
      if not page_fig_item.text:
        return
      else:
        page_fig_name_list.append(page_fig_item.text)
        for figure in fig_list:
          # We shouldn't have to url-encode this, but due to APERTA-6946 we must for now.
          assert urllib.quote_plus(figure) not in page_fig_name_list, \
              '{0} found in {1}'.format(urllib.quote_plus(figure), page_fig_name_list)
