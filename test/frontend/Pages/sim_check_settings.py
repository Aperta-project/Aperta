#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Page Object Model for the Similarity Check Settings Page, Workflow Tab. Validates elements and their styles,
and functions.
also includes
Page Object Model for the card settings overlay.
"""
import logging
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.PostgreSQL import PgSQL
from .styles import APERTA_BLUE
from .admin_workflows import AdminWorkflowsPage

__author__ = 'gtimonina@plos.org'


class SimCheckSettings(AdminWorkflowsPage):
  """
  Model the Similarity Check Settings Page, Workflow Tab elements and their functions
  """
  def __init__(self, driver):
    super(SimCheckSettings, self).__init__(driver)
    # locators for card settings overlay
    self._similarity_check_card = (By.XPATH, "//a[./span[contains(text(),'Similarity Check')]]")
    self._sim_check_card_settings = (By.XPATH, "//a[./span[contains(text(),'Similarity Check')]]//i")
    # setting edit page
    self._automatic_check_settings = (By.CLASS_NAME, 'similarity-check-settings')
    self._automatic_checks_text = (By.CSS_SELECTOR, '.similarity-check-settings h4')
    self._automatic_checks_slider_input = (By.CSS_SELECTOR, 'input#toogle')
    self._automatic_checks_slider = (By.CLASS_NAME, 'slider')#(By.ID, 'toogle')
    self._automatic_options = (By.CSS_SELECTOR, 'div.liquid-container>div')
    self._send_ms_on_submission_radio_button = (By.NAME, 'submissionOption')
    self._send_ms_after_revision_drop_list_collapsed = (By.CSS_SELECTOR, '.select2-container')
    self._send_ms_after_revision_input = (By.CSS_SELECTOR, 'input.select2-input')
    self._send_ms_after_revision_list_items = (By.CSS_SELECTOR, 'li.select2-result-selectable')
    self._after_revision_chosen = (By.CSS_SELECTOR, 'span.select2-chosen')
    self._after_revision_arrow = (By.CSS_SELECTOR, '.select2-arrow')
    self._sim_check_settings_save_button = (By.CSS_SELECTOR, 'div.overlay-action-buttons>button.button-primary')
    self._overlay_header_close = (By.CSS_SELECTOR, 'button.cancel')


  def open_mmt(self, mmt_name):
    """
    A function to open existing mmt
    :return: void function
    """
    self._wait_for_element(self._get(self._admin_workflow_pane_title))
    #self._wait_for_element(self._get(self._admin_workflow_mmt_thumbnail))
    mmts = self._gets(self._admin_workflow_mmt_thumbnail)
    for mmt in mmts:
      name = mmt.find_element(*self._admin_workflow_mmt_title)
      if name.text == mmt_name:
        logging.info('Opening {0} template'.format(name.text))
        self._scroll_into_view(name)
        name.click()
        break

  def click_on_card_settings(self, card_settings_locator):
    """
    A function to open card settings
    :return: void function
    """
    settings_icon = self._get(card_settings_locator)
    settings_icon.click()

  def close_mmt_card(self):
    self._wait_for_element(self._get(self._mmt_template_back_link))
    back_btn = self._get(self._mmt_template_back_link)
    back_btn.click()
    self._wait_for_element(self._get(self._admin_workflow_pane_title))

  def validate_setting_style_and_components(self):
    """Validate working of Similarity Check Settings overlay."""
    expected_overlay_title = 'Similarity Check: Settings'
    overlay_title = self._get(self._overlay_header_title)
    assert overlay_title.text == expected_overlay_title, 'The card title: {0} is not the expected: ' \
                                                         '{1}'.format(overlay_title.text, expected_overlay_title)
    #
    self.validate_overlay_card_title_style(overlay_title)

    auto_slider_input = self._iget(self._automatic_checks_slider_input)
    # start with automated setting is "off"
    if auto_slider_input.is_selected():
      self.set_automation(automation=False)
    assert self._check_for_absence_of_element(self._automatic_options)

    self.set_automation(automation=True)
    auto_slider_input = self._iget(self._automatic_checks_slider_input)
    assert auto_slider_input.is_selected(), 'Automation is expected to be ON'

    # validate instruction text when automation is ON
    automatic_checks_text = self._get(self._automatic_checks_text).text
    expected_instruction_text = 'Send Manuscript to iThenticate'
    assert expected_instruction_text in automatic_checks_text

    #validate radio buttons and dropdown options
    radio_buttons = self._gets(self._send_ms_on_submission_radio_button)
    on_first_submission = radio_buttons[0]
    after_revision = radio_buttons[1]
    assert on_first_submission.is_selected(), 'On first full submission option should be checked by default'
    assert not after_revision.is_selected(), 'After revisions option should be unchecked by default'
    #
    after_any = 'any first revision'
    after_minor = 'minor revision'
    after_major = 'major revision'
    after_revision.click()
    assert not on_first_submission.is_selected(), 'After submission option expected to be checked'
    assert after_revision.is_selected(),  'On first full submission option expected to be unchecked'
    # check options of the dropdown list
    self.select_and_validate_after_revision_option(after_major, 0)
    self.select_and_validate_after_revision_option(after_minor, 1)
    self.select_and_validate_after_revision_option(after_any, 2)

    cancel_link = self._get(self._overlay_header_close)
    self. validate_admin_link_style(cancel_link)


    save_overlay_button = self._get(self._sim_check_settings_save_button)
    assert save_overlay_button.text == 'SAVE'
    self.validate_primary_big_blue_button_style(save_overlay_button)


  def select_and_validate_after_revision_option(self, option_text, option_index):
    """
    function to select automatic Check send option, after revision
    :param option_text: expected option text for assertion
    :param option_number: option index in the option list (0-2)
    :return: None
    """
    after_revision_arrow = self._get(self._after_revision_arrow)
    after_revision_arrow.click()
    after_revision_options = self._gets(self._send_ms_after_revision_list_items)
    self._scroll_into_view(after_revision_options[option_index])
    after_revision_options[option_index].click()
    chosen_option = self._get(self._after_revision_chosen)
    assert chosen_option.text == option_text, chosen_option.text

  def save_settings(self):
    """
    function to save settings: click on 'SAVE' button on settings overlay
    :return: None
    """
    self._wait_for_element(self._get(self._sim_check_settings_save_button))
    save_overlay_button = self._get(self._sim_check_settings_save_button)
    save_overlay_button.click()


  def set_automation(self, automation=True):
    """
    function to set automated Similarity Check sending
    :param automation: boolean, True to set ON, False to set OFF
    :return: None
    """
    auto_slider_input = self._iget(self._automatic_checks_slider_input)
    if not automation == auto_slider_input.is_selected():
      automation_slider = self._get(self._automatic_checks_slider)
      automation_slider.click()

  def set_automation_after_submission(self, option_index = 0):
    """
    function to check radio button that defines trigger for automated Similarity Check
    :param option_index: 0 - to check option 'on first full submission', 1 - 'after revision'
    :return: None
    """
    radio_buttons = self._gets(self._send_ms_on_submission_radio_button)
    on_submission = radio_buttons[option_index]
    if not on_submission.is_selected():
      on_submission.click()