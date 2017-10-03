#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Page object definition for the Preprint Posting Overlay
"""

import logging
import random
import time

from selenium.webdriver.common.by import By

from frontend.Pages.authenticated_page import AuthenticatedPage

__author__ = 'jgray@plos.org'


class PreprintPostingOverlay(AuthenticatedPage):
  """
  Page Object Model for the Preprint posting overlay
  """

  def __init__(self, driver):
    super(PreprintPostingOverlay, self).__init__(driver)
    self._title = (By.CLASS_NAME, 'overlay-header-title')
    self._preprint_image = (By.CLASS_NAME, 'preprint-background-image')
    self._preprint_benefits = (By.TAG_NAME, 'li')
    self._preprint_content_text = (By.CSS_SELECTOR, 'p.content-text')
    self._preprint_content_text_em = (By.CSS_SELECTOR, 'p.content-text > b')
    self._preprint_input_radios = (By.TAG_NAME, 'input')
    self._preprint_input_radio_labels = (By.CSS_SELECTOR, 'span.card-content-radio-label')
    self._preprint_overlay_continue_btn = (By.TAG_NAME, 'button')

  def overlay_ready(self):
      self._wait_for_element(self._get(self._preprint_overlay_continue_btn))

  def validate_styles(self):
    """
    validate_styles: Validates the elements, styles and texts for the preprint posting overlay
    :return: void function
    """
    # Assert overlay title style
    overlay_title = self._get(self._title)
    expected_overlay_title = 'Post this paper as a preprint?'

    assert overlay_title.text == expected_overlay_title, 'The card title: {0} is not ' \
                                                         'the expected: {1}'.format(overlay_title.text,
                                                                                    expected_overlay_title)
    self.validate_overlay_card_title_style(overlay_title)
    expected_background_image = \
            '/assets/preprint-sample-44c043cb98f585b85799ac431f49d1578a397f835494763723783bbf8b9e9ab7.png'
    bg_image = self._get(self._preprint_image).value_of_css_property('background-image')
    assert expected_background_image in bg_image, bg_image

    benefits = self._gets(self._preprint_benefits)
    assert benefits[0].text.strip() == 'Benefit: Establish priority', benefits[0].text
    assert benefits[1].text.strip() == 'Benefit: Gather feedback', benefits[1].text
    assert benefits[2].text.strip() == 'Benefit: Cite for funding', benefits[2].text
    for benefit in benefits:
      self.validate_application_body_text(benefit)

    paragraph_text = self._get(self._preprint_content_text)
    expected_paragraph_text = 'Establish priority: take credit for your research and discoveries, by posting a copy ' \
                              'of your uncorrected proof online. If you do NOT consent to having an early version of ' \
                              'your paper posted online, indicate your choice below.'
    bold_p_text = self._get(self._preprint_content_text_em)
    expected_paragraph_text_em = 'NOT'
    assert expected_paragraph_text in paragraph_text.text, paragraph_text.text
    assert expected_paragraph_text_em in bold_p_text.text, bold_p_text.text
    self.validate_application_body_text(paragraph_text)

    radio_buttons = self._gets(self._preprint_input_radios)
    yes_radio = radio_buttons[0]
    no_radio = radio_buttons[1]
    self.validate_radio_button(yes_radio)
    self.validate_radio_button(no_radio)
    assert yes_radio.is_selected()
    radio_labels = self._gets(self._preprint_input_radio_labels)
    yes_radio_label = radio_labels[0]
    no_radio_label = radio_labels[1]
    expected_yes_radio_label = 'Yes, I want to accelerate research by publishing a preprint ahead of peer review'
    expected_no_radio_label = 'No, I do not want my article to appear online ahead of the reviewed article'
    assert expected_yes_radio_label in yes_radio_label.text, yes_radio_label.text
    assert expected_no_radio_label in no_radio_label.text, no_radio_label.text
    self.validate_radio_button_label(yes_radio_label)
    self.validate_radio_button_label(no_radio_label)

    continue_button = self._get(self._preprint_overlay_continue_btn)
    assert continue_button.text == 'CONTINUE'
    self.validate_primary_big_green_button_style(continue_button)

  def select_preprint_overlay_in_create_sequence_and_continue(self, selection=''):
      """
      Validate making a selection and closing the preprints overlay
      :param selection:  Yes or No, not specified will lead to random selection
      :return: Yes or No
      """
      radio_buttons = self._gets(self._preprint_input_radios)
      yes_radio = radio_buttons[0]
      no_radio = radio_buttons[1]
      if not selection:
          # not sure what we expect out of the gate, but I am putting my finger a little bit on the side of a No
          # selection - need to validate with business intelligence
          selection = random.choice(['Yes', 'No', 'No'])
      if selection.lower() == 'yes':
          yes_radio.click()
      elif selection.lower() == 'no':
          no_radio.click()
      else:
          raise(ValueError, 'Invalid selection for Preprint opt-in choice: {0}'.format(selection))
      continue_button = self._get(self._preprint_overlay_continue_btn)
      continue_button.click()
      logging.info('Preprint opt-in choice was: {0}'.format(selection))
      return selection
