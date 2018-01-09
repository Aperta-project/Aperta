#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Page object definition for the financial disclosure card
"""
from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'jgray@plos.org'


class FinancialDisclosureCard(BaseCard):
    """
    Page Object Model for the Financial Disclosure Card
    """
    def __init__(self, driver):
        super(FinancialDisclosureCard, self).__init__(driver)

        # Locators - Instance members
        self._intro_text = (By.CSS_SELECTOR, 'div.card-form-text-error')
        self._yes_radio = (By.TAG_NAME, 'div.card-radio input')
        self._yes_radio_label = (By.CSS_SELECTOR, 'div.card-radio input + span')
        self._yes_radio_required_icon = (By.CSS_SELECTOR,
                                         'div.card-radio input + span + span.required-field')
        self._no_radio = (By.CSS_SELECTOR, 'div.card-radio + div.card-radio input')
        self._no_radio_label = (By.CSS_SELECTOR, 'div.card-radio + div.card-radio input + span')
        self._no_radio_required_icon = (
            By.CSS_SELECTOR, 'div.card-radio + div.card-radio input + span + span.required-field')
        self._yes_subform_instruction_text = (By.CSS_SELECTOR, 'div.card-content-view-text')
        self._add_funder_link = (By.CSS_SELECTOR, 'a.add-repetition')
        self._funder_summary_div = (By.CSS_SELECTOR,
                                    'div.card-content-financial-disclosure-summary')
        self._funder_summary_intro_text = (By.CSS_SELECTOR,
                                           'div.card-content-financial-disclosure-summary > p')
        # The following locator can occur multiple times per summary div and should be used within
        #     a find_element structure
        self._funder_summary_statement = (By.CSS_SELECTOR,
                                          'div.card-content-financial-disclosure-summary > p div')
        self._subform_enclosing_div = (By.CSS_SELECTOR, 'div.repeated-block')
        # The following locators can occur for each subform enclosing div and should be used within
        #     a find_element structure
        self._subform_title = (By.TAG_NAME, 'h4')
        self._subform_funder_name_label = (By.CSS_SELECTOR, 'h4 + div > div > div')
        self._subform_funder_name_field = (By.CSS_SELECTOR, 'h4 + div > div > div > input')
        self._subform_grant_number_label = (By.CSS_SELECTOR, 'h4 + div + div > div > div')
        self._subform_grant_number_field = (By.CSS_SELECTOR, 'h4 + div + div > div > div > input')
        self._subform_website_label = (By.CSS_SELECTOR, 'h4 + div + div + div > div > div')
        self._subform_website_field = (By.CSS_SELECTOR, 'h4 + div + div + div > div > div > input')
        self._subform_addl_comments_label = (By.CSS_SELECTOR,
                                             'h4 + div + div + div + div > div > div')
        self._subform_addl_comments_field = (By.CSS_SELECTOR,
                                             'h4 + div + div + div + div > div > div > input')
        self._subform_funder_role_radio_question = (By.CSS_SELECTOR,
                                                    'fieldset > div.card-form-text')
        self._subform_funder_role_radio_yes = (By.CSS_SELECTOR, 'div.card-radio > label > input')
        self._subform_funder_role_radyes_lbl = (By.CSS_SELECTOR,
                                                'div.card-radio > label > input + span')
        self._subform_funder_role_yes_radio_required_icon = (
            By.CSS_SELECTOR, 'div.card-radio > label > input + span + span.required-field')
        self._subform_funder_role_radio_no = (
            By.CSS_SELECTOR, 'div.card-radio + div.card-radio > label > input + span')
        self._subform_funder_role_radno_lbl = (
          By.CSS_SELECTOR, 'div.card-radio + div.card-radio > label > input + span')
        self._subform_funder_role_no_radio_required_icon = (
            By.CSS_SELECTOR, 'div.card-radio + div.card-radio > label > input '
                             '+ span + span.required-field')
        self._subform_funder_role_field_label = (By.CSS_SELECTOR,
                                                 'fieldset > div.card-content-short-input')
        self._subform_funder_role_field = (
            By.CSS_SELECTOR, 'fieldset > div.card-content-short-input input.ember-text-field')

    # POM Actions
    def validate_styles(self):
      """
      Validate styles in the Financial Disclosure Card
      :return: void function
      """
      completed = self.completed_state()
      if completed:
        self.click_completion_button()
      card_title = self._get(self._card_heading)
      assert card_title.text == 'Financial Disclosure', card_title.text
      self.validate_overlay_card_title_style(card_title)
      intro_text = self._get(self._intro_text)
      self.validate_application_body_text(intro_text)
      assert intro_text.text == 'A copy of your uncorrected proof will be published online ahead ' \
                                'of the final version of your manuscript, should your manuscript ' \
                                'be accepted. If you do NOT consent to having an early version of ' \
                                'your paper published online, please uncheck the box below. Please ' \
                                'note, if you change your mind, you may choose to opt out up until ' \
                                'final acceptance.', intro_text.text
      opt_in_checkbox = self._get(self._accman_consent_checkbox)
      # APERTA-8500
      # self.validate_checkbox(opt_in_checkbox)
      assert opt_in_checkbox.is_selected(), 'Default value for EV should be selected, it isn\'t'
      opt_in_label = self._get(self._accman_consent_label)
      self.validate_checkbox_label(opt_in_label)

    def validate_state(self, selection_state=''):
      """
      Validate the Selection state in card view matches what is expected
      :param selection_state: The expected state of the card
      :return: void function
      """
      opt_in_checkbox = self._get(self._accman_consent_checkbox)
      assert selection_state in (True, False), 'Selection state can only be True or False. ' \
                                               'Supplied: {0}'.format(selection_state)
      if selection_state:
        try:
          opt_in_checkbox.is_selected()
        except:
          raise(ValueError, 'EV opt-in state expected to be True, '
                            'actual state: {0}'.format(not selection_state))
        return
      else:
        opt_in_checkbox.is_selected()
        try:
          assert opt_in_checkbox.is_selected()
        except AssertionError:
          return
        raise (ValueError, 'EV opt-in state expected to be False, '
                           'actual state: {0}'.format(not selection_state))
