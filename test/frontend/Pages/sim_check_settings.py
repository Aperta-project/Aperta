#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Page Object Model for the Similarity Check Settings Page on Workflow Tab.
Validates elements and their styles.
also includes Page Object Model for the card settings overlay,
locators and functions: set automation options for the Similarity Check Report to be
automatically triggered
"""

from selenium.webdriver.common.by import By

from .card_settings import CardSettings
from .styles import APERTA_BLUE, APERTA_GREY_DARK

__author__ = 'gtimonina@plos.org'


class SimCheckSettings(CardSettings):
    """
    Model the Similarity Check Settings Page on Workflow Tab, elements and their functions
    """

    def __init__(self, driver):
        super(SimCheckSettings, self).__init__(driver)
        # locators for card settings overlay
        self._similarity_check_card = (By.XPATH, "//a[./span[contains(text(),'Similarity Check')]]")
        self._sim_check_card_settings = (
            By.XPATH, "//a[./span[contains(text(),'Similarity Check')]]//i")
        # setting edit page
        self._automatic_check_settings = (By.CLASS_NAME, 'similarity-check-settings')
        self._automatic_checks_text = (By.CSS_SELECTOR, '.similarity-check-settings h4')
        self._automatic_checks_slider_input = (By.CSS_SELECTOR, 'input#toogle')
        self._automatic_checks_slider = (By.CLASS_NAME, 'slider')
        self._automatic_options = (By.CSS_SELECTOR, 'div.liquid-container>div')
        self._send_ms_on_submission_radio_button = (By.NAME, 'submissionOption')
        self._radio_button_labels = (By.CSS_SELECTOR, 'label.flex-element')
        self._send_ms_after_revision_drop_list_collapsed = (By.CSS_SELECTOR, '.select2-container')
        self._send_ms_after_revision_input = (By.CSS_SELECTOR, 'input.select2-input')
        self._send_ms_after_revision_list_items = (By.CSS_SELECTOR, 'li.select2-result-selectable')
        self._after_revision_chosen = (By.CSS_SELECTOR, 'span.select2-chosen')
        self._after_revision_arrow = (By.CSS_SELECTOR, '.select2-arrow')

    def validate_setting_style_and_components(self):
        """
        Validate style and components of Similarity Check Settings overlay.
        Style is defined by APERTA-10741
        :return: void function
        """
        auto_slider_input = self._iget(self._automatic_checks_slider_input)
        # default automated setting set to "off"
        if auto_slider_input.is_selected():
            self.set_automation(automation=False)
        assert self._check_for_absence_of_element(self._automatic_options), \
            'Automatic options should not be present if Automation is Off'

        self.set_automation(automation=True)
        auto_slider_input = self._iget(self._automatic_checks_slider_input)
        assert auto_slider_input.is_selected(), 'Automation is expected to be ON'

        # validate instruction text when automation is ON
        automatic_checks_text = self._get(self._automatic_checks_text).text
        expected_instruction_text = 'Send Manuscript to iThenticate'
        assert expected_instruction_text in automatic_checks_text

        # validate radio buttons and dropdown options
        radio_button_labels = self._gets(self._radio_button_labels)
        for label in radio_button_labels:
            self.validate_radio_button_label(label)
        radio_buttons = self._gets(self._send_ms_on_submission_radio_button)
        on_first_submission = radio_buttons[0]
        after_revision = radio_buttons[1]

        assert on_first_submission.is_selected(), 'On first full submission option ' \
                                                  'should be checked by default'
        assert not after_revision.is_selected(), 'After revisions option should be ' \
                                                 'unchecked by default'
        # check 'after revisions' option
        after_revision.click()
        assert not on_first_submission.is_selected(), 'After submission option expected ' \
                                                      'to be checked'
        assert after_revision.is_selected(), 'On first full submission option expected ' \
                                             'to be unchecked'
        # check options of the dropdown list
        self.select_and_validate_after_revision_option('major revision')
        self.select_and_validate_after_revision_option('minor revision')
        self.select_and_validate_after_revision_option('any first revision')

    def select_and_validate_after_revision_option(self, option_text):
        """
        function to select automatic Check send option, after revision
        :param option_text: expected option text for assertion
        :return: void function
        """
        after_revision_arrow = self._get(self._after_revision_arrow)
        after_revision_arrow.click()
        after_revision_options = self._gets(self._send_ms_after_revision_list_items)
        option_names = [option.text for option in after_revision_options]
        assert option_text in option_names
        for option in after_revision_options:
            if option.text == option_text:
                self._scroll_into_view(option)
                option.click()
                break

    def set_automation(self, automation=True):
        """
        function to set automated Similarity Check sending
        :param automation: boolean, True to set ON, False to set OFF
        :return: void function
        """
        auto_slider_input = self._iget(self._automatic_checks_slider_input)
        expected_background_color = APERTA_BLUE if auto_slider_input.is_selected() \
            else APERTA_GREY_DARK
        if not automation == auto_slider_input.is_selected():
            automation_slider = self._get(self._automatic_checks_slider)
            assert automation_slider.value_of_css_property(
                    'background-color') == expected_background_color, \
                automation_slider.value_of_css_property('background-color')
            automation_slider.click()

    def set_after_submission_option(self, option_index=0):
        """
        function to check radio button that defines trigger for automated Similarity Check
        :param option_index: 0 - to check option 'on first full submission', 1 - 'after revision'
        :return: void function
        """
        radio_buttons = self._gets(self._send_ms_on_submission_radio_button)
        on_submission = radio_buttons[option_index]
        if not on_submission.is_selected():
            on_submission.click()

    def set_ithenticate(self, auto_option='off'):
        """
        Set Similarity Check automation options
        :param: auto_option: string: one of the options: 'off', 'at_first_full_submission',
        'after_major_revise_decision', 'after_minor_revise_decision',
        'after_any_first_revise_decision'
        :return: void function
        """
        if auto_option == 'off':
            self.set_automation(automation=False)
        else:
            self.set_automation(automation=True)
            if auto_option == 'at_first_full_submission':
                self.set_after_submission_option(0)  # after first submission
            else:
                self.set_after_submission_option(1)  # after revision
                if auto_option == 'after_major_revise_decision':
                    self.select_and_validate_after_revision_option('major revision')
                elif auto_option == 'after_minor_revise_decision':
                    self.select_and_validate_after_revision_option('minor revision')
                elif auto_option == 'after_any_first_revise_decision':
                    self.select_and_validate_after_revision_option('any first revision')
