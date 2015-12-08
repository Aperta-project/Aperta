#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Admin Page. Validates global and dynamic elements and their styles
"""

import random
import time

from selenium.webdriver.common.by import By

from Base.PostgreSQL import PgSQL
from Base.Resources import sa_login
from authenticated_page import AuthenticatedPage, application_typeface, tahi_blue, white

__author__ = 'jgray@plos.org'


class AdminPage(AuthenticatedPage):
  """
  Model an aperta Admin page
  still have to user details update
  """
  def __init__(self, driver, url_suffix='/'):
    super(AdminPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # Base Admin Page
    self._base_admin_user_search_field = (By.CLASS_NAME, 'admin-user-search-input')
    self._base_admin_user_search_button = (By.CLASS_NAME, 'admin-user-search-button')
    self._base_admin_user_search_default_state_text = (By.CLASS_NAME, 'admin-user-search-default-state-text')
    self._base_admin_user_search_results_table = (By.CLASS_NAME, 'admin-users')
    self._base_admin_user_search_results_table_fname_header = (By.XPATH, '//table[@class="admin-users"]/tr/th[1]')
    self._base_admin_user_search_results_table_lname_header = (By.XPATH, '//table[@class="admin-users"]/tr/th[2]')
    self._base_admin_user_search_results_table_uname_header = (By.XPATH, '//table[@class="admin-users"]/tr/th[3]')
    self._base_admin_user_search_results_row = (By.CLASS_NAME, 'user-row')

    self._base_admin_journals_section_title = (By.CLASS_NAME, 'admin-section-title')

    self._base_admin_journals_su_add_new_journal_btn = (By.CLASS_NAME, 'add-new-journal')

    self._base_admin_journals_edit_journal_div = (By.CLASS_NAME, 'journal-thumbnail-edit-form')
    self._base_admin_journals_edit_logo_upload_btn = (By.CLASS_NAME, 'fileinput-button')
    self._base_admin_journals_edit_logo_upload_note = (By.CLASS_NAME, 'journal-thumbnail-logo-upload-note')
    self._base_admin_journals_edit_title_label = (By.XPATH, '//div[@class="inset-form-control-text"]/label')
    self._base_admin_journals_edit_title_field = (By.XPATH, '//div[@class="inset-form-control required "]/input')
    self._base_admin_journals_edit_desc_label = (By.XPATH, '//div[@class="inset-form-control required "][2]/div/label')
    self._base_admin_journals_edit_desc_field = (By.XPATH, '//div[@class="inset-form-control required "][2]/textarea')
    self._base_admin_journals_edit_cancel_link = (By.XPATH, '//div[@class="journal-edit-buttons"]/a[1]')
    self._base_admin_journals_edit_save_button = (By.XPATH, '//div[@class="journal-edit-buttons"]/a[2]')

    self._base_admin_journals_section_journal_block = (By.CLASS_NAME, 'journal-thumbnail')

    # User Details Overlay
    self._ud_overlay_uname_label = (By.XPATH, "//label[@for='user-detail-username']")
    self._ud_overlay_uname_field = (By.ID, 'user-detail-username')
    self._ud_overlay_fname_label = (By.XPATH, "//label[@for='user-detail-first-name']")
    self._ud_overlay_fname_field = (By.ID, 'user-detail-first-name')
    self._ud_overlay_lname_label = (By.XPATH, "//label[@for='user-detail-last-name']")
    self._ud_overlay_lname_field = (By.ID, 'user-detail-last-name')
    self._ud_overlay_reset_pw_btn = (By.CSS_SELECTOR, 'div.reset-password a')
    self._ud_overlay_reset_pw_success_msg = (By.CLASS_NAME, 'success')

  # POM Actions
  def validate_page_elements_styles_functions(self, username):
    # Validate User section elements
    self._get(self._base_admin_user_search_field)
    self._get(self._base_admin_user_search_button)
    self._get(self._base_admin_user_search_default_state_text)
    # Validate Journals section elements
    journals_title = self._get(self._base_admin_journals_section_title)
    self.validate_application_h2_style(journals_title)
    if username == sa_login:
      self._get(self._base_admin_journals_su_add_new_journal_btn)
      # Validate the presentation of journal blocks
      # Super Admin gets all journals
      db_journals = PgSQL().query('SELECT journals.name,journals.description,count(papers.id)'
                                  'FROM journals LEFT JOIN papers '
                                  'ON journals.id = papers.journal_id '
                                  'GROUP BY journals.id;')
    else:
      # Ordinary Admin role is assigned on a per journal basis
      uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
      roles = PgSQL().query('SELECT role_id FROM user_roles WHERE user_id = %s;', (uid,))
      role_list = []
      for role in roles:
        role_list.append(role[0])
      journals = []
      for role in role_list:
        journals.append(PgSQL().query('SELECT journal_id FROM roles WHERE id = %s;', (role,))[0][0])
      db_journals = []
      for journal in journals:
        db_journals.append(PgSQL().query('SELECT journals.name, journals.description, count(papers.id) '
                                         'FROM journals LEFT JOIN papers '
                                         'ON journals.id = papers.journal_id '
                                         'WHERE journals.id = %s '
                                         'GROUP BY journals.id;', (journal,))[0])
    journal_blocks = self._gets(self._base_admin_journals_section_journal_block)
    count = 0
    for journal_block in journal_blocks:
      # Once again, while less than ideal, these must be defined on the fly
      self._base_admin_journal_block_paper_count = \
          (By.XPATH,
           '//div[@class="ember-view journal-thumbnail"][%s]/a/span[@class="journal-thumbnail-paper-count"]'
           % str(count + 1))
      self._base_admin_journal_block_name = \
          (By.XPATH, '//div[@class="ember-view journal-thumbnail"][%s]/a/h3[@class="journal-thumbnail-name"]'
           % str(count + 1))
      self._base_admin_journal_block_desc = (By.XPATH, '//div[@class="ember-view journal-thumbnail"][%s]/a/p'
                                             % str(count + 1))

      journal_paper_count = self._get(self._base_admin_journal_block_paper_count)
      journal_title = self._get(self._base_admin_journal_block_name)
      journal_desc = self._iget(self._base_admin_journal_block_desc).text
      if len(journal_desc) == 0:
        journal_desc = None
      journal_t = (journal_title.text, journal_desc, long(journal_paper_count.text.split()[0]))
      assert journal_t in db_journals, '{} not found in \n{}'.format(journal_t, db_journals)
      count += 1

  def validate_add_new_journal(self, username):
    if username == sa_login:
      self._get(self._base_admin_journals_su_add_new_journal_btn)
      db_initial_journal_count = int(PgSQL().query('SELECT count(*) from journals')[0][0])
      page_initial_journal_count = self._gets(self._base_admin_journals_section_journal_block)
      anj_button = self._get(self._base_admin_journals_su_add_new_journal_btn)
      assert anj_button.text == 'ADD NEW JOURNAL'
      self.validate_primary_big_blue_button_style(anj_button)
      self._actions.move_to_element(anj_button).perform()
      anj_button.click()
      page_secondary_journal_count = self._gets(self._base_admin_journals_section_journal_block)
      assert len(page_initial_journal_count) == db_initial_journal_count
      assert len(page_initial_journal_count) + 1 == len(page_secondary_journal_count)
      # Stopping here as I don't want to automatedly create a journal without a clean means
      # of deleting the same. Need to ask after a safe method of deleting a created journal to move forward
      upload_button = self._get(self._base_admin_journals_edit_logo_upload_btn)
      assert upload_button.text == 'UPLOAD NEW'
      self.validate_blue_on_blue_button_style(upload_button)
      self._actions.move_to_element(upload_button).perform()
      time.sleep(2)
      assert upload_button.value_of_css_property('color') == tahi_blue
      assert upload_button.value_of_css_property('background-color') == white
      upload_note = self._get(self._base_admin_journals_edit_logo_upload_note)
      assert upload_note.text == '(250px x 40px)'
      assert application_typeface in upload_note.value_of_css_property('font-family')
      assert upload_note.value_of_css_property('font-size') == '14px'
      assert upload_note.value_of_css_property('font-style') == 'italic'
      assert upload_note.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
      assert upload_note.value_of_css_property('line-height') == '40px'
      assert upload_note.value_of_css_property('padding-left') == '10px'
      journal_title_label = self._get(self._base_admin_journals_edit_title_label)
      assert journal_title_label.text == 'Journal Title'
      self.validate_input_field_label_style(journal_title_label)
      journal_title_field = self._get(self._base_admin_journals_edit_title_field)
      assert journal_title_field.get_attribute('placeholder') == 'PLOS Yeti'
      assert application_typeface in journal_title_field.value_of_css_property('font-family')
      assert journal_title_field.value_of_css_property('font-size') == '14px'
      assert journal_title_field.value_of_css_property('font-weight') == '400'
      assert journal_title_field.value_of_css_property('font-style') == 'normal'
      assert journal_title_field.value_of_css_property('color') == 'rgba(85, 85, 85, 1)'
      assert journal_title_field.value_of_css_property('line-height') == '20px'
      assert journal_title_field.value_of_css_property('padding-left') == '12px'
      journal_desc_label = self._get(self._base_admin_journals_edit_desc_label)
      assert journal_desc_label.text == 'Journal Description'
      self.validate_input_field_label_style(journal_desc_label)
      journal_desc_field = self._get(self._base_admin_journals_edit_desc_field)
      assert journal_desc_field.get_attribute('placeholder') == 'Accelerating the publication of peer-reviewed science'
      assert application_typeface in journal_desc_field.value_of_css_property('font-family')
      assert journal_desc_field.value_of_css_property('font-size') == '14px'
      assert journal_desc_field.value_of_css_property('font-weight') == '400'
      assert journal_desc_field.value_of_css_property('font-style') == 'normal'
      assert journal_desc_field.value_of_css_property('color') == 'rgba(85, 85, 85, 1)'
      assert journal_desc_field.value_of_css_property('line-height') == '20px'
      assert journal_desc_field.value_of_css_property('padding-left') == '12px'
      save_button = self._get(self._base_admin_journals_edit_save_button)
      assert save_button.text == 'SAVE'
      self.validate_blue_on_blue_button_style(save_button)
      self._actions.move_to_element(anj_button).perform()
      self._actions.move_to_element(save_button).perform()
      time.sleep(2)
      assert save_button.value_of_css_property('color') == tahi_blue, save_button.value_of_css_property('color')
      assert save_button.value_of_css_property('background-color') == white, \
          save_button.value_of_css_property('background-color')
      cancel_link = self._get(self._base_admin_journals_edit_cancel_link)
      assert cancel_link.text == 'Cancel'
      assert application_typeface in cancel_link.value_of_css_property('font-family')
      assert cancel_link.value_of_css_property('font-size') == '14px'
      assert cancel_link.value_of_css_property('font-weight') == '400'
      assert cancel_link.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
      assert cancel_link.value_of_css_property('background-color') == 'transparent'
      assert cancel_link.value_of_css_property('line-height') == '20px'
      assert cancel_link.value_of_css_property('text-align') == 'center'
      assert cancel_link.value_of_css_property('vertical-align') == 'middle'
      self._actions.move_to_element(cancel_link).perform()
      time.sleep(1)
      assert cancel_link.value_of_css_property('text-decoration') == 'underline'
      self._actions.move_to_element(cancel_link).perform()
      cancel_link.click()
      page_tertiary_journal_count = self._gets(self._base_admin_journals_section_journal_block)
      assert len(page_tertiary_journal_count) == db_initial_journal_count

  def validate_search_edit_user(self, username):
    initial_user_state_text = self._get(self._base_admin_user_search_default_state_text)
    assert initial_user_state_text.text == 'Need to find a user? Search for them here.'
    self._search_user('')
    time.sleep(1)  # sadly one needs to allow time for the result set to update from the server
    no_result_search_text = self._get(self._base_admin_user_search_default_state_text).text
    assert no_result_search_text == 'No matching users found'
    self._search_user(username)
    self._get(self._base_admin_user_search_results_table)
    self._get(self._base_admin_user_search_results_table_fname_header)
    self._get(self._base_admin_user_search_results_table_lname_header)
    self._get(self._base_admin_user_search_results_table_uname_header)
    # TODO: Determine the search heuristic and enforce it. It seems overly broad currently.
    result_set = self._gets(self._base_admin_user_search_results_row)
    success_count = 0
    for result in result_set:
      if username in result.text:
        success_count += 1
      result.click()
      # TODO: Validate Styles for these elements
      time.sleep(.5)
      user_details_title = self._get(self._overlay_header_title)
      user_details_closer = self._get(self._overlay_header_close)
      user_details_fname_label = self._get(self._ud_overlay_fname_label)
      user_details_fname_field = self._get(self._ud_overlay_fname_field)
      user_details_lname_label = self._get(self._ud_overlay_lname_label)
      user_details_lname_field = self._get(self._ud_overlay_lname_field)
      user_details_uname_label = self._get(self._ud_overlay_uname_label)
      user_details_uname_field = self._get(self._ud_overlay_uname_field)
      user_details_reset_pw_btn = self._get(self._ud_overlay_reset_pw_btn)
      user_details_reset_pw_btn.click()
      user_details_reset_pw_success_msg = self._get(self._ud_overlay_reset_pw_success_msg)
      user_details_cancel_link = self._get(self._overlay_action_button_cancel)
      user_details_save_btn = self._get(self._overlay_action_button_save)
      user_details_closer.click()
    assert success_count > 0

  def _search_user(self, username):
    user_search_field = self._get(self._base_admin_user_search_field)
    user_search_btn = self._get(self._base_admin_user_search_button)
    user_search_field.clear()
    user_search_field.send_keys(username)
    user_search_btn.click()

  def select_random_journal(self):
    journal_blocks = self._gets(self._base_admin_journals_section_journal_block)
    selected_journal = random.choice(journal_blocks)
    print('Opening ' + selected_journal.find_element(*self._base_admin_journal_block_name).text + ' journal.')
    selected_journal.find_element(*self._base_admin_journal_block_name).click()

  # TODO: Create method to create journal PLOS Wombat if not exist

  # TODO: Create method to create NoCards and OnlyInitialDecisionCard MMT in PLOS Wombat if not exist
