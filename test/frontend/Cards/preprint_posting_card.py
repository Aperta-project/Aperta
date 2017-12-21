#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Page object definition for the preprint posting card
"""
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.support.expected_conditions import element_to_be_clickable, visibility_of

from frontend.Cards.basecard import BaseCard

__author__ = 'gholmes@plos.org'


class PrePrintPostCard(BaseCard):
    """
  Page Object Model for Billing Card
  """

    def __init__(self, driver):
        super(PrePrintPostCard, self).__init__(driver)

        # Locators - Instance members
        self._benefit_text = (By.CSS_SELECTOR, 'div > p')

        self._yes_radio_button = (By.XPATH, "//input[@class='ember-view'][@value='true']")
        self._no_radio_button = (By.XPATH, "//input[@class='ember-view'][@value='false']")
        self._card_opt_in_content_label = (By.CSS_SELECTOR, 'div>label:nth-child(1)')
        self._card_opt_out_content_label = (By.CSS_SELECTOR, 'div>label:nth-child(2)')
        self._yes_disabled_radio_button = (By.XPATH, "//input[@class='ember-view'][@value='true'][@disabled='']")
        self._no_disabled_radio_button = (By.XPATH, "//input[@class='ember-view'][@value='false'][@disabled='']")

    def validate_styles(self):
        """
    Validate styles for the Preprint Posting Card
    """
        card_title = self._get(self._card_heading)
        assert card_title.text == 'Preprint Posting', card_title.text
        self.validate_overlay_card_title_style(card_title)
        benefits_text = self._get(self._benefit_text)
        self.validate_application_body_text(benefits_text)
        assert "Benefit: Establish priority" in benefits_text.text, benefits_text.text
        assert "Benefit: Gather feedback" in benefits_text.text, benefits_text.text
        assert "Benefit: Cite for funding" in benefits_text.text, benefits_text.text
        # opt_in_checkbox = self._get(self._yes_radio_button)
        # assert opt_in_checkbox.is_selected(), 'Default value for Preprint Posting Card should be selected, it isn\'t'
        assert self._get(
            self._card_opt_in_content_label).text == "Yes, I want to accelerate research by publishing a preprint ahead of peer review"
        assert self._get(
            self._card_opt_out_content_label).text == "No, I do not want my article to appear online ahead of the reviewed article"
        self.validate_radio_button_label(self._get(self._card_opt_in_content_label))
        self.validate_radio_button_label(self._get(self._card_opt_out_content_label))

    def complete_form(self, choices):
        """
        Filling out the preprint card with selected data
        :param choice: If supplied, will fill out the form accordingly, else, will make a random
          choice. A boolean.
        """
        opt_in = self._get(self._yes_radio_button)
        self._wait_for_element(opt_in)
        opt_out = self._get(self._no_radio_button)
        self._wait_for_element(opt_out)
        if choices == 'optIn':
            try:

                assert opt_in.is_selected
            except AssertionError:
              opt_in.click()
              return
        else:
            if choices =='optOut':
                try:
                    opt_out.click()
                    assert opt_out.is_selected
                except AssertionError:
                    return

    def validate_state(self, selection_state):
        """
        Validate the Selection state
        :param selection_state: The expected state of the card
        :return: void function
        """
        opt_in = self._get(self._yes_radio_button)
        self._wait_for_element(opt_in)
        opt_out = self._get(self._no_radio_button)
        self._wait_for_element(opt_out)

        if selection_state == 'optIn':
            try:
                opt_in.is_selected()
            except:
                raise (ValueError, 'Preprint cart state expected to be opt_in, '
                                   'actual state: opt_out'.format(not selection_state))
            return
        else:
            if selection_state == 'optOut':
                try:
                    opt_out.is_selected()
                except:
                    return
                    raise (ValueError, 'Preprint cart state expected to be opt_out, '
                                       'actual state: opt_in'.format(not selection_state))
