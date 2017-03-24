#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the base Admin Page, Settings Tab. Validates elements and their styles,
and functions.
"""
import logging
import time

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError
from base_admin import BaseAdminPage

__author__ = 'jgray@plos.org'


class AdminSettingsPage(BaseAdminPage):
  """
  Model the common base Admin page, Settings Tab elements and their functions
  """
  def __init__(self, driver):
    super(AdminSettingsPage, self).__init__(driver)

    # Locators - Instance members
    self._admin_settings_pane_title = (By.CSS_SELECTOR, 'div.admin-page-content > div > h2')
    self._admin_settings_pane_alljournals_placeholder_heading = (By.CSS_SELECTOR,
                                                                 'div.admin-journal-settings > h4')
    # Edit journal form section
    self._admin_setings_edit_journal_div = (By.CLASS_NAME, 'journal-thumbnail-edit-form')
    self._admin_settings_edit_logo_upload_btn = (By.CLASS_NAME, 'fileinput-button')
    self._admin_settings_edit_logo_upload_note = (By.CLASS_NAME,
                                                       'journal-thumbnail-logo-upload-note')
    self._admin_settings_edit_logo_input_field = (By.ID, 'journal-logo-null')
    self._admin_settings_edit_title_label = (By.CSS_SELECTOR,
                                                 'div.inset-form-control-text > label')
    self._admin_settings_edit_title_field = (By.CSS_SELECTOR, 'div.inset-form-control > input')
    self._admin_settings_edit_desc_label = (
        By.CSS_SELECTOR, 'div.inset-form-control + div.inset-form-control '
                         '> div.inset-form-control-text > label')
    self._admin_settings_edit_desc_field = (
        By.CSS_SELECTOR, 'div.inset-form-control + div.inset-form-control > textarea')
    self._admin_settings_edit_doi_jrnl_prefix_label = (
        By.CSS_SELECTOR, 'div.inset-form-control + div.inset-form-control + div.inset-form-control '
                         '> div.inset-form-control-text > label')
    self._admin_settings_edit_doi_jrnl_prefix_field = (By.CLASS_NAME,
                                                            'journal-doi-journal-prefix-edit')
    self._admin_settings_edit_doi_publ_prefix_label = (
        By.CSS_SELECTOR, 'div.inset-form-control + div.inset-form-control + div.inset-form-control '
                         '+ div.inset-form-control > div.inset-form-control-text > label')
    self._admin_settings_edit_doi_publ_prefix_field = (By.CLASS_NAME,
                                                            'journal-doi-publisher-prefix-edit')
    self._admin_settings_edit_last_doi_label = (
        By.CSS_SELECTOR, 'div.inset-form-control + div.inset-form-control + div.inset-form-control '
                         '+ div.inset-form-control + div.inset-form-control > '
                         'div.inset-form-control-text > label')
    self._admin_settings_edit_last_doi_field = (By.CLASS_NAME, 'journal-last-doi-edit')
    self._admin_settings_edit_cancel_link = (By.XPATH,
                                                  '//div[@class="journal-edit-buttons"]/a[1]')
    self._admin_settings_edit_save_button = (By.XPATH,
                                                  '//div[@class="journal-edit-buttons"]/a[2]')

    # Style Settings Section
    self._admin_settings_edit_pdf_css_btn = (By.ID, 'edit-pdf-css')
    self._admin_settings_edit_ms_css_btn = (By.ID, 'edit-manuscript-css')

    self._journal_styles_css_overlay_field_label = (By.CSS_SELECTOR, 'div.overlay-header + p')
    self._journal_styles_css_overlay_field = (By.CSS_SELECTOR, 'div.overlay-header + p + textarea')
    self._journal_styles_css_overlay_cancel = (By.CSS_SELECTOR, 'div.overlay-action-buttons a')
    self._journal_styles_css_overlay_save = (By.CSS_SELECTOR,
                                             'div.overlay-action-buttons a + button')

  # POM Actions
  def page_ready(self):
    """"Ensure the page is ready to test"""
    self._wait_for_element(self._get(self._admin_settings_pane_title))

  def validate_settings_pane(self, selected_jrnl):
    """
    Assert the existence and function of the elements of the Settings pane.
    Validate Add new template, edit/delete existing templates, validate presentation.
    :param selected_jrnl: The name of the selected journal for which to validate the workflow pane
    :return: void function
    """
    logging.info('Validating settings display for {0}.'.format(selected_jrnl))
    # Time to fully populate Settings for selected journal
    time.sleep(1)
    if selected_jrnl in ('All My Journals', 'All'):
      alljournals_subhead = self._get(self._admin_settings_pane_alljournals_placeholder_heading)
      assert alljournals_subhead.text == 'Please select a specific journal ' \
                                         'to modify.', alljournals_subhead.text
    else:
      # We have a regular journal so all elements present
      users_pane_title = self._get(self._admin_settings_pane_title)
      self.validate_application_h2_style(users_pane_title)
      assert 'Journal Settings' in users_pane_title.text, users_pane_title.text
      self.validate_edit_journal(selected_jrnl)
      self.validate_style_settings_section()

  def validate_edit_journal(self, journal):
    """
    Validates the edit function of the named journal
    :param journal: The name of the journal chosen for the settings pane
    :return: void function
    """
    logging.info('Validating editing journal: {0}'.format(journal))
    upload_button = self._get(self._admin_settings_edit_logo_upload_btn)
    assert upload_button.text == 'UPLOAD NEW', upload_button.text
    self.validate_blue_on_blue_button_style(upload_button)
    journal_title_label = self._get(self._admin_settings_edit_title_label)
    assert journal_title_label.text == 'Journal Title', journal_title_label.text
    journal_title_field = self._get(self._admin_settings_edit_title_field)
    assert journal_title_field.get_attribute('value') == journal, \
        journal_title_field.get_attribute('value')
    journal_desc_label = self._get(self._admin_settings_edit_desc_label)
    assert journal_desc_label.text == 'Journal Description', journal_desc_label.text
    # APERTA-6829
    # self.validate_input_field_inside_label_style(journal_desc_label)
    self._get(self._admin_settings_edit_desc_field)
    save_button = self._get(self._admin_settings_edit_save_button)
    assert save_button.text == 'SAVE', save_button.text
    # Our style fu is exceedingly weak!
    # APERTA-9597
    # self.validate_blue_on_blue_button_style(save_button)
    cancel_link = self._get(self._admin_settings_edit_cancel_link)
    assert cancel_link.text == 'cancel', cancel_link.text
    cancel_link.click()

  def validate_style_settings_section(self):
    """
    Validate the CSS style section elements and functions of the Admin Settings page
    :return: void function
    """
    edit_pdf_css_btn = self._get(self._admin_settings_edit_pdf_css_btn)
    assert edit_pdf_css_btn.text == 'EDIT PDF CSS', edit_pdf_css_btn.text
    edit_pdf_css_btn.click()
    self._wait_for_element(self._get(self._overlay_header_close))
    title = self._get(self._overlay_header_title)
    assert 'PDF CSS' in title.text, title.text
    label = self._get(self._journal_styles_css_overlay_field_label)
    assert label.text == 'Enter or edit CSS to format the PDF output for this '\
        'journal\'s papers.', label.text
    self._get(self._journal_styles_css_overlay_field)
    cancel = self._get(self._journal_styles_css_overlay_cancel)
    self._get(self._journal_styles_css_overlay_save)
    cancel.click()
    self._wait_for_not_element(self._overlay_header_close, .25)
    edit_ms_css_btn = self._get(self._admin_settings_edit_ms_css_btn)
    assert edit_ms_css_btn.text == 'EDIT MANUSCRIPT CSS', edit_ms_css_btn.text
    edit_ms_css_btn.click()
    self._wait_for_element(self._get(self._overlay_header_close))
    title = self._get(self._overlay_header_title)
    assert 'Manuscript CSS' in title.text, title.text
    label = self._get(self._journal_styles_css_overlay_field_label)
    assert label.text == 'Enter or edit CSS to format the manuscript editor and output for '\
        'this journal.', label.text
    self._get(self._journal_styles_css_overlay_field)
    self._get(self._journal_styles_css_overlay_cancel)
    save = self._get(self._journal_styles_css_overlay_save)
    save.click()
