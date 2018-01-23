#!/usr/bin/env python3
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
        self._yes_radio = (By.CSS_SELECTOR, 'div.card-radio input')
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
        # The following locators can occur multiple times per summary div and should be used within
        #     a find_element structure
        self._funder_summary_statement = (By.CSS_SELECTOR,
                                          'div.card-content-financial-disclosure-summary > p div')
        self._subform_enclosing_div = (By.CSS_SELECTOR, 'div.repeated-block')
        # The following locators can occur for each subform enclosing div and should be used within
        #     a find_element structure
        self._subform_title = (By.TAG_NAME, 'h4')
        self._subform_funder_name_label = (By.CSS_SELECTOR, 'div.qa-ident-funder--name > div > div')
        self._subform_funder_name_field = (By.CSS_SELECTOR,
                                           'div.qa-ident-funder--name > div > div + div > input')
        self._subform_grant_number_label = (By.CSS_SELECTOR,
                                            '.qa-ident-funder--grant_number > div > div')
        self._subform_grant_number_field = (By.CSS_SELECTOR,
                                            '.qa-ident-funder--grant_number > div > div > input')
        self._subform_website_label = (By.CSS_SELECTOR, '.qa-ident-funder--website > div > div')
        self._subform_website_field = (By.CSS_SELECTOR,
                                       '.qa-ident-funder--website > div > div > input')
        self._subform_addl_comments_label = (By.CSS_SELECTOR,
                                             '.qa-ident-funder--additional_comments > div > div')
        self._subform_addl_comments_field = (
            By.CSS_SELECTOR, '.qa-ident-funder--additional_comments > div > div > input')
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
    def validate_state(self, choice, name, grant, site, comment, subform_role_choice, role):
        """
        Validate the card view matches what was entered in task view
        :param choice: top level radio selection Yes or No
        :param name: the funder name
        :param grant: the funder grant number
        :param site: the funder website
        :param comment: the comment about the funder
        :param subform_role_choice: whether the funder had a role in the study Yes or No
        :param role: the role of the funder
        :return: void function
        """
        yes_rad = self._get(self._yes_radio)
        no_rad = self._get(self._no_radio)
        if choice == 'Yes':
            yes_rad.is_selected()
            subform_encl_div = self._get(self._subform_enclosing_div)
            funder_subform_name = subform_encl_div.find_element(*self._subform_funder_name_field)
            assert funder_subform_name.get_attribute('value') == name, \
                funder_subform_name.get_attribute('value')
            funder_subform_grant = subform_encl_div.find_element(*self._subform_grant_number_field)
            assert funder_subform_grant.get_attribute('value') == grant, \
                funder_subform_grant.get_attribute('value')
            funder_subform_site = subform_encl_div.find_element(*self._subform_website_field)
            assert funder_subform_site.get_attribute('value') == site, \
                funder_subform_site.get_attribute('value')
            funder_subform_comments = subform_encl_div.find_element(
                *self._subform_addl_comments_field)
            assert funder_subform_comments.get_attribute('value') == comment, \
                funder_subform_comments.get_attribute('value')
            if subform_role_choice == 'Yes':
                funder_subform_role = \
                    subform_encl_div.find_element(*self._subform_funder_role_field)
                subform_encl_div.find_element(*self._subform_funder_role_radio_yes).is_selected()
                assert funder_subform_role.get_attribute('value') == role, \
                    funder_subform_role.get_attribute('value')
            else:
                subform_encl_div.find_element(*self._subform_funder_role_radio_no).is_selected()
        else:
            no_rad.is_selected()
