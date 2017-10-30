#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.PostgreSQL import PgSQL
from frontend.Cards.basecard import BaseCard

__author__ = 'gtimonina@plos.org'

class SimilarityCheckCard(BaseCard):
  """
  Page object for the Similarity Check card
  """
  def __init__(self, driver):
    super(SimilarityCheckCard, self).__init__(driver)

    # Locators - Instance members
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
    # (By.CSS_SELECTOR, 'div.overlay-action-buttons>button.cancel')
    # mmt card locators
    self._sim_check_task_overlay = (By.CSS_SELECTOR, '.task.similarity-check-task')
    self._instruction = (By.CSS_SELECTOR, 'div.ember-view.task>div>p')
    self._automation_disabled_info = (By.CSS_SELECTOR, 'div.auto-report-off p')
    self._automated_report_status = (By.CSS_SELECTOR, '.task.similarity-check-task p')
    self._automated_report_status_active = (By.CSS_SELECTOR, 'div.automated-report-status p')  # 2 lines
    self._generate_report_button = (By.CSS_SELECTOR, 'button.generate-confirm')
    self._confirm_container = (By.CSS_SELECTOR, 'div.confirm-container')
    self._confirm_text = (By.CSS_SELECTOR, 'div.confirm-container>h4')
    self._manually_generate_cancel_link = (By.CSS_SELECTOR, 'button.button-link')  # 'div.confirm-container>button.button-link'
    self._manually_generate_button = (By.CSS_SELECTOR, 'button.generate-report')  # 'div.confirm-container>button.generate-report'
    self._report_pending_spinner = (By.CSS_SELECTOR, 'div.progress-spinner')
    self._report_pending_spinner_message = (By.CSS_SELECTOR, 'div.ember-view.progress-spinner-message')
    self._sim_check_report_title = (By.CLASS_NAME, 'latest-versioned-text>h3')
    self._sim_check_report_completed = (By.CSS_SELECTOR, '.latest-versioned-text p')
    self._sim_check_report_score_text = (By.CSS_SELECTOR, '.latest-versioned-text p + p')
    self._sim_check_report_link = (By.CSS_SELECTOR, '.similarity-check a')
    self._sim_check_report_score = (By.CLASS_NAME, 'score')
    self._sim_check_report_history = (By.CSS_SELECTOR, '.task.similarity-check-task>div>h3')
    self._sim_check_report_revision_number = (By.CSS_SELECTOR, 'similarity-check-bar-revision-number')
    #
    self._ithenticate_title = (By.CSS_SELECTOR, 'div.infobar-title')
    self._ithenticate_result = (By.CSS_SELECTOR, 'div.infobar-value')
    self._btn_done = (By.CSS_SELECTOR, 'span.task-completed-section button')

  # POM Actions
  def validate_styles_and_components(self, ithenticate_automation='off'):
    """
    Validate styles in the Similarity Check Card
    :return: void function
    """
    # AC#4
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Similarity Check'
    self.validate_overlay_card_title_style(card_title)

    # AC 4.1
    card_instruction = self._get(self._instruction)
    expected_instruction = 'Click below to generate a similarity report via iThenticate. ' \
                           'If a report was generated for a previous version it can be found ' \
                           'in the version history.'
    assert card_instruction.text.strip() == expected_instruction, card_instruction.text.strip()
    self.validate_application_body_text(card_instruction)

    # AC 4.2  Button to send for manual report
    # AC 4.2.1  The button is only enabled if:
    # AC 4.2.1.1 ... the card is marked incomplete

    # APERTA-9958
    auto_report_options = {'at_first_full_submission': 'first full submission',
                           'after_major_revise_decision': 'major revision',
                           'after_minor_revise_decision': 'minor revision',
                           'after_any_first_revise_decision': 'any first revision'}

    # ithenticate_automation = 'off'
    if ithenticate_automation == 'off':
      auto_info = self._get(self._automation_disabled_info)
      assert auto_info.text.strip() == 'Automated similarity check is disabled:'
    else:
      auto_info = self._gets(self._automated_report_status_active)
      expected_text = 'Automated similarity check is active: ' \
                      'This manuscript will be sent to iThenticate on ' + \
                      auto_report_options[ithenticate_automation] + '.'
      assert auto_info[0].text.strip() == expected_text
      assert auto_info[1].text.strip() == 'Manually generating a report below will disable ' \
                                          'the automated similarity check for this manuscript.'

    if ithenticate_automation == 'at_first_full_submission':
      # check it is pending and "generate button is not enabled
      send_for_manual_report_button = self._iget(self._generate_report_button)
      assert not send_for_manual_report_button.is_enabled()
      try:
        report_pending_spinner_message = self._get(self._report_pending_spinner_message)
        assert "Pending" in report_pending_spinner_message.text # send_for_manual_report_button self._generate_report_button disabled
      except ElementDoesNotExistAssertionError:
        # that means the report is already ready
        # check if Report is ready
        report_title = self._get(self._sim_check_report_title)
        assert 'Similarity Check Report' in report_title.text.strip()

    else:
      # check if the button is enable if the card is incomplete
      self.validate_generate_report_button()
      self.click_completion_button() # mark task as complete
      # check if the button is disable if the card is complete
      self.validate_generate_report_button()
      self.click_completion_button() # mark task as incomplete
      # AC 4.2.1.2 ... a manuscript file is present - skipped as not valid test case (it should not be possible
      # to submit manuscript without manuscript file

      # AC 4.2.2 .The button triggers a confirm/cancel step before generation a report
      send_for_manual_report_button = self._get(self._generate_report_button)
      self.validate_primary_big_green_button_style(send_for_manual_report_button)
      send_for_manual_report_button.click()
      # confirm/cancel container
      self._wait_for_element(self._get(self._confirm_container))
      assert self._get(self._confirm_container)
      confirm_container = self._get(self._confirm_container)
      self.validate_generate_confirmation_style(confirm_container)

      confirm_text = self._get(self._confirm_text)
      expected_confirm_text = 'Manually generating the report will disable the automated similarity check for this manuscript'
      assert expected_confirm_text == confirm_text.text.strip()
      confirm_cancel = self._get(self._manually_generate_cancel_link)
      assert confirm_cancel # cancel link
      self.validate_cancel_confirmation_style(confirm_cancel)

      confirm_generate_button = self._get(self._manually_generate_button)
      assert confirm_generate_button.text == 'GENERATE REPORT' # confirm button
      self.validate_secondary_big_green_button_style(confirm_generate_button)
      # click on 'cancel' - confirm container should not be displayed
      confirm_cancel.click()
      gen_report = self._get(self._sim_check_task_overlay)
      gen_report.find_element_by_css_selector('div div')

      assert 'confirm-container' not in gen_report.get_attribute('class')
      # click "GENERATE REPORT' again
      self.validate_generate_report_button()


  def generate_manual_report(self):

    send_for_manual_report_button = self._get(self._generate_report_button)
    send_for_manual_report_button.click()

    # AC 4.2.1.3 ... the report status is not pending
    confirm_generate_button = self._get(self._manually_generate_button)
    confirm_generate_button.click()
    report_pending_spinner_message = self._get(self._report_pending_spinner_message)
    assert "Pending" in report_pending_spinner_message.text
    # self.validate_progress_spinner_style(report_pending_spinner_message)
    # TODO: add assert for AC 4.2.1.3 when APERTA-11392 gets resolved
    # assert not send_for_manual_report_button.is_displayed

  def validate_report_result(self):

    self._wait_for_element(self._get(self._sim_check_report_title), 1)
    report_title = self._get(self._sim_check_report_title)
    assert 'Similarity Check Report' in report_title.text.strip()
    self.validate_application_h3_style(report_title)
    html_header_title = self._get(self._header_title_link)
    paper_title = html_header_title.text
    # wait for completed report
    self._wait_for_element(self._get(self._sim_check_report_completed))
    report_completed = self._get(self._sim_check_report_completed)
    self._wait_on_lambda(lambda: self.completed_state()==True, max_wait=300)
    #self._wait_for_element(self._get(self._sim_check_report_link), 1000)
    score = self._get(self._sim_check_report_score)
    score = score.text
    self.launch_ithenticate_page(score, paper_title)


  def launch_ithenticate_page(self, score, paper_title):
    report_link = self._get(self._sim_check_report_link)
    assert self._is_link_valid(report_link), 'Report link {0} is invalid'.report_link.get_attribute('href')
    report_link.click()
    self.traverse_to_new_window()
    self._wait_for_element(self._get(self._ithenticate_title))
    ithent_title = self._get(self._ithenticate_title)
    assert paper_title.strip() == ithent_title.text.strip()

    self._wait_for_element(self._get(self._ithenticate_result))
    ithent_score = self._get(self._ithenticate_result)
    assert score.strip() in ithent_score.text.strip()

  def validate_generate_report_button(self, ):
    card_completed_state = self.completed_state()
    send_for_manual_report_button = self._iget(self._generate_report_button)
    if card_completed_state:
      assert not send_for_manual_report_button.is_displayed()
    else:
      assert send_for_manual_report_button.is_displayed()

  def validate_generate_confirmation_style(self, confirm_container):
    """
    Ensure consistency in rendering cancel link across confirmation
    :param cancel: Cancel element
    """
    assert 'source-sans-pro' in confirm_container.value_of_css_property('font-family'), \
        confirm_container.value_of_css_property('font-family')
    assert confirm_container.value_of_css_property('font-size') == '14px', \
        confirm_container.value_of_css_property('font-size')
    assert confirm_container.value_of_css_property('font-weight') == '400', \
        confirm_container.value_of_css_property('font-weight')
    assert confirm_container.value_of_css_property('line-height') == '20px', \
        confirm_container.value_of_css_property('line-height')
    assert confirm_container.value_of_css_property('color') == 'rgb(255, 255, 255)', \
        confirm_container.value_of_css_property('color')
    assert confirm_container.value_of_css_property('text-align') == 'center', \
        confirm_container.value_of_css_property('text-align')
    assert confirm_container.value_of_css_property('background-color') == 'rgb(57, 163, 41)', \
        confirm_container.value_of_css_property('background-color')

  def set_automation_db(self, mmt_id, auto_option='off'):

    settings_id, settings_owner_id, settings_owner_type, settings_name, \
    settings_string_value, settings_type, settings_created_at, settings_updated_at, \
    settings_value_type, settings_setting_template_id = \
    PgSQL().query('SELECT settings.id, settings.owner_id, settings.owner_type, '
                  'settings.name, settings.string_value, settings.type, '
                  'settings.created_at, settings.updated_at, settings.value_type, '
                  'settings.setting_template_id'
                  'FROM task_templates, phase_templates, settings '
                  'WHERE phase_templates.manuscript_manager_template_id = %s '
                  'AND phase_templates.id=task_templates.phase_template_id '
                  'AND settings.owner_id=task_templates.id '
                  'AND task_templates.title= %s '
                  'AND settings.NAME = %s;', (mmt_id, 'Similarity Check',
                                              'ithenticate_automation'))[0]
    if auto_option != settings_string_value:
      PgSQL().modify('INSERT INTO settings (id, owner_id, owner_type, name, string_value, type, '
                     'created_at, updated_at, value_type, setting_template_id) '
                     'VALUES (%s, %s, %s, %s, %s, %s, '
                     'now(), now(), %s, %s);',
                     (settings_id, settings_owner_id, settings_owner_type, settings_name, \
                      auto_option, settings_type, settings_created_at, settings_updated_at, \
                      settings_value_type, settings_setting_template_id))
