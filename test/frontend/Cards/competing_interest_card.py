#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Page object definition for the Competing Interest card
"""
import random
import time

from pip.utils import logging
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.support.expected_conditions import element_to_be_clickable, visibility_of

from frontend.Cards.basecard import BaseCard

__author__ = 'gholmes@plos.org'


class CompetingInterestCard(BaseCard):
    """
  Page Object Model for Competing Interest Card
  """

    def __init__(self, driver):
        super(CompetingInterestCard, self).__init__(driver)
        self._intro_text = (By.CSS_SELECTOR, '.question-text>P')
        self._card_yes_label = (By.XPATH, ("//*[@class='card-form-label'][contains(text(),'Yes')]"))
        self._card_no_label =  (By.XPATH, ("//*[@class='card-form-label'][contains(text(),'No')]"))

    def validate_styles(self):
        """
               Filling out the preprint card with selected data
               :param choices: If supplied, will fill out the form accordingly, else, will make a random
                 choice. A boolean.
               """
        intro_text = self._get(self._intro_text)
        # self.validate_application_body_text(intro_text)
        assert intro_text.text == 'You are responsible for recognizing and disclosing on behalf of all authors ' \
                              'any competing interest that could be perceived to bias their work, ' \
                              'acknowledging all financial support and any other relevant financial ' \
                              'or non-financial competing interests.', intro_text.text
        yes_label = self._get(self._card_yes_label)
        self.validate_checkbox_label(yes_label)
        no_label = self._get(self._card_no_label)
        self.validate_checkbox_label(no_label)

    def complete_form(self, choices):
        """
        Filling out the preprint card with selected data
        :param choices: If supplied, will fill out the form accordingly, else, will make a random
          choice. A boolean.
        """
        yes_button = self._get(self._card_yes_label)
        self._wait_for_element(yes_button)
        no_button = self._get(self._card_no_label)
        self._wait_for_element(no_button)
        if choices == 'yes':
            try:
                yes_button.click()
            except AssertionError:
                assert yes_button.is_selected

                return
        else:
            if choices == 'no':
                try:
                    no_button.click()
                except AssertionError:
                    assert no_button.is_selected

                    return
    def validate_state(self, selection_state):
        """
        Validate the Selection state
        :param selection_state: The expected state of the card
        :return: void function
        """
        yes_button = self._get(self._card_yes_label)
        self._wait_for_element(yes_button)
        no_button = self._get(self._card_no_label)
        self._wait_for_element(no_button)

        if selection_state == 'yes':
            try:
                yes_button.is_selected()
            except ValueError:
                raise (ValueError, 'Completed Interest state expected to be yes, '
                                   'actual state: no'.format(not selection_state))
            return
        else:
            if selection_state == 'no':
                try:
                    no_button.is_selected()
                except ValueError:
                    raise (ValueError, 'Completed Interest state expected to be no, '
                                       'actual state: yes'.format(not selection_state))
