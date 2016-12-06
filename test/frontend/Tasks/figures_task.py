#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random
import time
import urllib

from selenium.common.exceptions import WebDriverException
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import StaleElementReferenceException, NoSuchElementException

from Base.Config import wait_timeout
from Base.CustomException import ElementDoesNotExistAssertionError, ElementExistsAssertionError
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
    self._intro_text_p1 = (By.CSS_SELECTOR, 'div.task-main-content > p')
    self._intro_text_p1_link = (By.CSS_SELECTOR, 'div.task-main-content > p > a')
    self._intro_text_p2 = (By.CSS_SELECTOR, 'div.task-main-content > p + p')
    self._intro_text_p2_link1 = (By.CSS_SELECTOR, 'div.task-main-content > p + p > a')
    self._intro_text_p2_link2 = (By.CSS_SELECTOR, 'div.task-main-content > p + p > a + a')
    self._question_label = (By.CLASS_NAME, 'question-checkbox')
    self._question_check = (By.CLASS_NAME, 'ember-checkbox')
    self._labels_intro_p1 = (By.CSS_SELECTOR, 'div.task-main-content > div + p')
    self._add_new_figures_btn = (By.CLASS_NAME, 'button-primary')
    self._figures_list = (By.ID, 'figure-list')
    self._figure_listing = (By.CSS_SELECTOR, 'div.liquid-child > div.ember-view')
    self._figure_preview = (By.CSS_SELECTOR, 'img.image-thumbnail')
    self._figure_label = (By.CSS_SELECTOR, 'h2.title')
    self._figure_striking_chkmrk = (By.CSS_SELECTOR, 'div.striking > i.fa-check')
    self._figure_striking_status = (By.CSS_SELECTOR, 'div.striking')
    self._figure_error_msg_a = (By.CSS_SELECTOR, 'div.info > h2 + div.error-message')
    self._figure_error_icon = (By.CSS_SELECTOR, 'i.fa-exclamation-triangle')
    self._figure_dl_link = (By.CSS_SELECTOR, 'div.download-link > a')
    self._figure_replace_btn = (By.CSS_SELECTOR, 'div.replace-file-button')
    self._figure_replace_input = (By.CSS_SELECTOR, 'input.ember-text-field')
    self._figure_error_msg_b = (By.CSS_SELECTOR,
                                'div.info > div.replace-file-button + div.error-message')
    self._figure_edit_icon = (By.CSS_SELECTOR, 'div.edit-icons > span.fa-pencil')
    self._figure_edit_label_prefix = (By.CSS_SELECTOR, 'div.title > h2')
    self._figure_edit_label_field = (By.CSS_SELECTOR, 'div.title > h2 > input')
    self._figure_edit_striking_img_checkbox_lbl = (By.CSS_SELECTOR, 'div.striking > label')
    self._figure_edit_striking_img_checkbox = (By.CSS_SELECTOR, 'div.striking > label > input')
    self._figure_edit_cancel_link = (By.CSS_SELECTOR, 'div.actions > a.button-link')
    self._figure_edit_save_btn = (By.CSS_SELECTOR, 'div.actions > a.button-primary')
    self._figure_delete_icon = (By.CSS_SELECTOR, 'div.edit-icons > span.fa-trash')
    self._figure_delete_confirmation = (By.CSS_SELECTOR, 'div.delete-confirmation')
    self._figure_delete_confirm_line1 = (By.CSS_SELECTOR, 'div.delete-confirmation > h4')
    self._figure_delete_confirm_line2 = (By.CSS_SELECTOR, 'div.delete-confirmation > h4 + h4')
    self._figure_delete_confirm_cancel = (By.CSS_SELECTOR, 'div.delete-confirmation > a')
    self._figure_delete_confirm_confirm = (By.CSS_SELECTOR, 'div.delete-confirmation > button')
    self._figure_processing_div = (By.CSS_SELECTOR, 'div.loading')
    self._figure_processing_spinner = (By.CSS_SELECTOR, 'div.progress-spinner')
    self._figure_processing_text = (By.CSS_SELECTOR, 'div.progress-text')
    self._figure_processing_cancel = (By.CSS_SELECTOR, 'a.upload-cancel-link')


  # POM Actions
  def validate_styles(self):
    """
    Validate styles in Figures Task
    """
    error_msg = ''
    intro_text_p1 = self._get(self._intro_text_p1)
    # The intro paragraph is rendered in the incorrect font size
    # self.validate_application_ptext(intro_text)
    assert intro_text_p1.text == (
        'Please confirm that your figures comply with our guidelines for preparation and '
        'have not been inappropriately manipulated. For information on image manipulation, '
        'please see our general guidance notes on image manipulation.'), intro_text_p1.text
    intro_text_p1_link = self._get(self._intro_text_p1_link)
    assert 'general guidance' in intro_text_p1_link.text, intro_text_p1_link.text
    assert intro_text_p1_link.get_attribute('href') == \
        'http://journals.plos.org/plosbiology/s/figures#loc-image-manipulation', \
        intro_text_p1_link.get_attribute('href')
    intro_text_p2 = self._get(self._intro_text_p2)
    assert intro_text_p2.text == (
        'We recommend that you use the PACE tool to prepare your figures for submission according '
        'to our figure requirements.'), intro_text_p2.text
    intro_text_p2_link1 = self._get(self._intro_text_p2_link1)
    assert 'PACE' in intro_text_p2_link1.text, intro_text_p2_link1.text
    assert intro_text_p2_link1.get_attribute('href') == 'http://pace.apexcovantage.com/', \
        intro_text_p2_link1.get_attribute('href')
    intro_text_p2_link2 = self._get(self._intro_text_p2_link2)
    assert 'figure requirements' in intro_text_p2_link2.text, intro_text_p2_link2.text
    assert intro_text_p2_link2.get_attribute('href') == \
        'http://journals.plos.org/plosbiology/s/aperta-user-guide-for-authors#loc-figures', \
        intro_text_p2_link2.get_attribute('href')
    assert self._get(self._question_label).text == 'Yes - I confirm our figures comply with the ' \
                                                   'guidelines.'
    self.validate_application_ptext(self._get(self._question_label))
    labels_intro = self._get(self._labels_intro_p1)
    assert labels_intro.text == (
        'Figure labels (e.g. Fig 1) are generated from file names and will automatically place '
        'figures above matching legends.'), labels_intro.text
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
      self._wait_for_element(self._get(self._question_check))
      self._get(self._question_check).click()
      self.click_completion_button()

  def is_question_checked(self):
    """
    Checks if checkmark for the question on Figures task is applied or not
    :return: Bool
    """
    self.set_timeout(60)
    question_check = self._get(self._question_check)
    self.restore_timeout()
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
    current_path = os.getcwd()
    # Download tests change dir to /tmp. If for some reason, they do not return to the correct
    #   directory, catch and abort - no good will follow
    assert current_path != '/tmp', 'WARN: Get current working directory returned ' \
                                   'incorrect value, aborting: {0}'.format(current_path)
    self._reset_position_to_conformance_question()
    for iteration in range(0, iterations):
      if figure2send == 'random':
        figure = random.choice(figure_candidates_list)
        fn = os.path.join(current_path, figure)
      else:
        figure = figure2send
        fn = os.path.join(current_path, figure)
      logging.info('Sending figure: {0}'.format(fn))
      time.sleep(1)
      self._driver.find_element_by_id('figure_attachment').send_keys(fn)
      add_new_figures_btn = self._get(self._add_new_figures_btn)
      self.scroll_element_into_view_below_toolbar(add_new_figures_btn)
      add_new_figures_btn.click()
      self._validate_processing(figure)
      self._driver.find_element_by_id('figure_attachment').clear()
      figure_candidates_list.remove(figure)
      chosen_figures_list.append(figure)
      logging.info('Figure List so far: {0}'.format(chosen_figures_list))
      self.check_for_flash_error()
    return chosen_figures_list

  def replace_figure(self, figure2replace='', replacement_figure=''):
    """
    Function to replace and existing figure file
    :param replacement_figure: The name of the new figure, if not specified a random figure will be
      chosen.
    :param figure2replace: Name of the figure to replace
    :return a list containing the filename of the new figure
    """
    current_path = os.getcwd()
    # Download tests change dir to /tmp. If for some reason, they do not return to the correct
    #   directory, catch and abort - no good will follow
    assert current_path != '/tmp', 'WARN: Get current working directory returned ' \
                                   'incorrect value, aborting: {0}'.format(current_path)
    if not replacement_figure:
      logging.info('No specific replacement figure specified, choosing random figure.')
      # Creating a fresh copy of the list to get around a stale reference error
      remaining_figures = figures
      new_figure = random.choice(remaining_figures)
    else:
      new_figure = replacement_figure
    fn = os.path.join(current_path, new_figure)
    logging.info('Replacing figure: {0}, with {1}'.format(figure2replace, new_figure))
    self._reset_position_to_conformance_question()
    figure_listings = self._gets(self._figure_listing)
    for figure_listing in figure_listings:
      page_fig_name = figure_listing.find_element(*self._figure_dl_link)
      if page_fig_name.text == figure2replace:
        logging.info('Found a match for figure to replace: {0}'.format(figure2replace))
        figure_listing.find_element(*self._figure_replace_btn)
        replace_input = figure_listing.find_element(*self._figure_replace_input)
        # Apparently one doesn't need to click the replace button - sending the file triggers
        #   the upload.
        replace_input.send_keys(fn)
    self._validate_processing(replacement_figure)

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
    self._reset_position_to_conformance_question()
    self._wait_for_element(self._gets(self._figure_dl_link)[0])
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
        try:
          delete_icon.click()
        except WebDriverException:
          self.click_covered_element(delete_icon)
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
    self._reset_position_to_conformance_question()
    if not figure:
      raise (ValueError, 'A figure was not specified')
    logging.info('Downloading figure: {0}'.format(figure))
    time.sleep(5)
    page_fig_list = self._gets(self._figure_dl_link)
    for page_fig_item in page_fig_list:
      for fig in figure:
        fig = urllib.quote_plus(fig)
        if fig in page_fig_item.text:
          logging.debug('Match!')
          try:
            page_fig_item.click()
          except WebDriverException:
            self.click_covered_element(page_fig_item)
          time.sleep(1)
          orig_dir = os.getcwd()
          # If anything fails between the next line and line 333, we end up in a bogus state for
          #   the next test
          os.chdir('/tmp')
          files = filter(os.path.isfile, os.listdir('/tmp'))
          files = [os.path.join('/tmp', f) for f in files]  # add path to each file
          files.sort(key=lambda x: os.path.getmtime(x))
          logging.info(files)
          # the following can fail if other processes write/clean-up files in /tmp
          try:
            newest_file = files[-1]
          except IndexError:
            os.chdir(orig_dir)
            logging.warning('Another process may deleted files from /tmp. While rare, '
                            'this should not be considered a failure.')
            return
          logging.debug(newest_file)
          while newest_file.split('.')[-1] == 'part':
            time.sleep(5)
            files = filter(os.path.isfile, os.listdir('/tmp'))
            files = [os.path.join('/tmp', f) for f in files]  # add path to each file
            files.sort(key=lambda x: os.path.getmtime(x))
            logging.info(files)
            try:
              newest_file = files[-1]
            except IndexError:
              os.chdir(orig_dir)
              logging.warning('Another process may deleted files from /tmp. While rare, '
                              'this should not be considered a failure.')
              return
            logging.debug(newest_file.split('.')[-1])
          newest_file = newest_file.split('/')[-1]
          # doing the following ahead of the assert to ensure we end up in the right directory
          #   whether the assert fails or succeeds
          os.remove(newest_file)
          os.chdir(orig_dir)
          try:
            assert fig == newest_file, 'Figure from page: {0} doesn\'t match the newest file ' \
                                       'in the /tmp directory: {1}. This should usually succeed ' \
                                       'but when the OS is active it can fail and be ' \
                                       'fine.'.format(fig, newest_file)
          except AssertionError:
            logging.warning('Newest file: {0} is not the file we expected: {1}. '
                            'Another process may have written to /tmp'.format(newest_file, fig))
          return
    if not matched:
      raise(ElementDoesNotExistAssertionError, 'No match found for {0}'.format(figure))

  def edit_figure(self, figure=''):
    """
    Function to edit the named figure file, also validates the styles of the edit components
    :param figure: Name of the figure to edit.
    :return void function
    """
    matched = False
    if not figure:
      raise(ValueError, 'A figure must be specified')
    logging.info(figure)
    figure = urllib.quote_plus(figure)
    self._reset_position_to_conformance_question()
    # Redefining this down here to avoid a stale element reference due to the listing having
    #   been replaced, potentially, since lookup
    self._figure_listing = (By.CSS_SELECTOR, 'div.liquid-child > div.ember-view')
    figure_blocks = self._gets(self._figure_listing)
    original_order = []
    final_order = []
    for figure_block in figure_blocks:
      page_fig_name = figure_block.find_element(*self._figure_dl_link)
      original_order.append(page_fig_name.text)
    logging.info(original_order)
    for figure_block in figure_blocks:
      page_fig_name = figure_block.find_element(*self._figure_dl_link)
      if figure in page_fig_name.text:
        logging.info('Editing figure: {0}'.format(figure))
        self.scroll_by_pixels(-60)
        # Move to item to get the edit icons to appear
        self._actions.move_to_element(figure_block).perform()
        edit_icon = figure_block.find_element(*self._figure_edit_icon)
        self._actions.move_to_element(edit_icon).perform()
        try:
          edit_icon.click()
        except WebDriverException:
          self.click_covered_element(edit_icon)
        time.sleep(1)
        label_prefix = figure_block.find_element(*self._figure_edit_label_prefix)
        assert 'Fig.' in label_prefix.text, label_prefix.text
        label_field = figure_block.find_element(*self._figure_edit_label_field)
        assert label_field.get_attribute('value') == '1', label_field.get_attribute('value')
        striking_label = figure_block.find_element(*self._figure_edit_striking_img_checkbox_lbl)
        assert 'This is the striking image' in striking_label.text, striking_label.text
        striking_chkbx = figure_block.find_element(*self._figure_edit_striking_img_checkbox)
        assert striking_chkbx.is_selected() == False, striking_chkbx.is_selected()
        cancel_link = figure_block.find_element(*self._figure_edit_cancel_link)
        assert 'cancel' in cancel_link.text, cancel_link.text
        save_link = figure_block.find_element(*self._figure_edit_save_btn)
        assert 'SAVE' in save_link.text, save_link.text
        striking_chkbx.click()
        assert striking_chkbx.is_selected() == True, striking_chkbx.is_selected()
        self._reset_position_to_conformance_question()
        try:
          label_field.click()
          label_field.send_keys(Keys.ARROW_DOWN + Keys.ENTER)
        except WebDriverException:
          self.click_covered_element(label_field)
          label_field.send_keys(Keys.ARROW_DOWN + Keys.ENTER)
        time.sleep(.5)
        try:
          save_link.click()
        except WebDriverException:
          self.click_covered_element(save_link)
        time.sleep(5)
        matched = True
    # time for order of blocks to update - often very slow - particularly when on Heroku CI
    time.sleep(20)
    figure_blocks = self._gets(self._figure_listing)
    # Test still occasionally failing for second block not redrawing yet
    count = 0
    while len(figure_blocks) < 2:
      # It takes some time after the block initially draws for the content to populate
      time.sleep(5)
      figure_blocks = self._gets(self._figure_listing)
      count += 1
      if count >= 9:
        raise(AssertionError, 'On edit, a minute passed without figure blocks ordering properly')
    for figure_block in figure_blocks:
      page_fig_name = figure_block.find_element(*self._figure_dl_link)
      logging.info(page_fig_name.text)
      count = 0
      while not page_fig_name.text:
        time.sleep(5)
        page_fig_name = figure_block.find_element(*self._figure_dl_link)
        count += 1
        if count > 10:
          raise(StandardError, 'Figure block not populating correctly - not getting a figure name')
      final_order.append(page_fig_name.text)
    original_order.sort()
    assert original_order == final_order, 'Original Order sorted: {0} != ' \
                                          'Final Order{1}'.format(original_order, final_order)
    self._validate_striking_image_set(figure)
    if not matched:
      logging.info('no match found')

  def validate_figure_presence(self, fig_list):
    """
    Given a list of figures (file titles), validated they are all present on the Figures task
    :param fig_list: list of file names
    :return: boolean, true if all passed filenames appear on the figures card
    """
    self._wait_for_element(self._gets(self._figure_dl_link)[0])
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

  def _validate_striking_image_set(self, figure):
    """
    Given a figure name, validate it is set as striking image candidates
    :param figure: filename of image
    :return: void function
    """
    logging.info(figure)
    matched = False
    # Redefining this down here to avoid a stale element reference due to the listing having
    #   been replaced, potentially, since lookup
    self._figure_listing = (By.CSS_SELECTOR, 'div.liquid-child > div.ember-view')
    figure_blocks = self._gets(self._figure_listing)
    for figure_block in figure_blocks:
      page_fig_name = figure_block.find_element(*self._figure_dl_link)
      if figure == page_fig_name.text:
        matched = True
        page_strike_status = figure_block.find_element(*self._figure_striking_status)
        figure_block.find_element(*self._figure_striking_chkmrk)
        assert 'This is the striking image' in page_strike_status.text, page_strike_status.text
    if not matched:
      raise(ValueError, 'Figure list: {0} not found on page'.format(figure))

  def _reset_position_to_conformance_question(self):
    """
    Resets the scrolled position to the figure guideline conformance question. This should put
      the first figure block below the toolbar.
    """
    guidelines_question = self._get(self._question_label)
    self.scroll_element_into_view_below_toolbar(guidelines_question)

  def _validate_processing(self, figure):
    """
    Check for the existence of the processing elements of file upload (also replace)
    :param figure: The name of the figure - for reference in case of timeout.
    :return: void function
    """
    try:
      self._wait_for_element(self._get(self._figure_processing_div), multiplier=1)
    except ElementDoesNotExistAssertionError:
      logging.info('The spinner either cleared too fast, or never appeared.')

    # Check for processing elements, then when they disappear, move on. The loading div
    #   Can disappear at any time during this check, so wrap in a try/except block
    try:
      self.set_timeout(1)
      self._get(self._figure_processing_spinner)
      processing_stanza = self._get(self._figure_processing_text)
      assert processing_stanza.text == u'Figure Processing ... but you can continue ' \
                                       u'working!', processing_stanza.text
      processing_cancel_link = self._get(self._figure_processing_cancel).text
      assert processing_cancel_link == 'cancel', 'Processing Cancel link text: {0} is not ' \
                                                 'what is expected: ' \
                                                 'cancel'.format(processing_cancel_link)
      # THIS IS THE spot to wait for an element to NOT be in the DOM
      multiplier = 2  # timeout multiplier
      try:
        self._wait_for_not_element(self._figure_processing_div, multiplier)
      except ElementExistsAssertionError:
        disappearance_timeout = wait_timeout * multiplier
        logging.error('Figure processing took longer than {0} seconds for '
                      'figure: {1}'.format(disappearance_timeout, figure))
    except ElementDoesNotExistAssertionError:
      logging.info('The loading div cleared before all elements could be verified')
      self.restore_timeout()
