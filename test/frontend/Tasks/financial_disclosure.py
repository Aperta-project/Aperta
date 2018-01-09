#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random

from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask

__author__ = 'jgray@plos.org'


class FinancialDisclosureTask(BaseTask):
    """
    Page Object Model for Early Version task
    """

    def __init__(self, driver):
        super(FinancialDisclosureTask, self).__init__(driver)

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
        Validate styles in the Financial Disclosure Task
        """
        intro_text = self._get(self._intro_text)
        self.validate_application_body_text(intro_text)
        assert intro_text.text == 'Did any of the authors receive specific funding for this ' \
                                  'work?', intro_text.text
        yes_rad = self._get(self._yes_radio)
        assert not yes_rad.selected()
        yes_lbl = self._get(self._yes_radio_label)
        assert yes_lbl.text == 'Yes', yes_lbl.text
        self._get(self._yes_radio_required_icon)
        no_rad = self._get(self._no_radio)
        assert not no_rad.selected()
        no_lbl = self._get(self._no_radio_label)
        assert no_lbl.text == 'No', no_lbl.text
        self._get(self._no_radio_required_icon)
        self._check_for_invisible_element(self._yes_subform_instruction_text)
        self._check_for_invisible_element(self._add_funder_link)
        self._check_for_invisible_element(self._funder_summary_div)
        self._check_for_invisible_element(self._funder_summary_intro_text)
        # The following locator can occur multiple times per summary div and should be used within
        #     a find_element structure
        self._check_for_invisible_element(self._funder_summary_statement)
        self._subform_enclosing_div
        # The following locators can occur for each subform enclosing div and should be used within
        #     a find_element structure
        self._subform_title
        self._subform_funder_name_field
        self._subform_grant_number_label
        self._subform_grant_number_field
        self._subform_website_label
        self._subform_website_field
        self._subform_addl_comments_label
        self._subform_addl_comments_field
        self._subform_funder_role_radio_question
        self._subform_funder_role_radio_yes
        self._subform_funder_role_radyes_lbl
        self._subform_funder_role_yes_radio_required_icon
        self._subform_funder_role_radio_no
        self._subform_funder_role_radno_lbl
        self._subform_funder_role_no_radio_required_icon
        self._subform_funder_role_field_label
        self._subform_funder_role_field

    def complete_form(self, choice=''):
        """
        Fill out the single item EV form with supplied data or random data if none provided
        :param choice: If supplied, will fill out the form accordingly, else, will make a random
          choice. A boolean.
        :returns choice: the selection to opt in or opt out, a boolean. (True=Opt in; False=Opt out)
        """
        choices = [True, False]
        already_deselected = False
        opt_in_checkbox = self._get(self._accman_consent_checkbox)
        if choice:
            assert choice in choices, 'Selected can only be True or False. Supplied: ' \
                                      '{0}'.format(choice)
        else:
            choice = random.choice(choices)
        logging.info('Early Version selection is: {0}'.format(choice))
        if choice:
            try:
                assert opt_in_checkbox.is_selected()
            except AssertionError:
                opt_in_checkbox.click()
        else:
            try:
                assert opt_in_checkbox.is_selected()
            except AssertionError:
                already_deselected = True
            if not already_deselected:
                opt_in_checkbox.click()
            self.pause_to_save()
        return choice
