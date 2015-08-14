#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Admin Page. Validates global and dynamic elements and their styles
"""

import time

from selenium.webdriver.common.by import By

from Base.PostgreSQL import PgSQL
from authenticated_page import AuthenticatedPage

__author__ = 'jgray@plos.org'


class AdminPage(AuthenticatedPage):
  """
  Model an aperta Admin page
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

    self._base_admin_journals_section_title = (By.CLASS_NAME, 'admin-section-title')

    self._base_admin_journals_su_add_new_journal_btn = (By.CLASS_NAME, 'add-new-journal')

    self._base_admin_journals_edit_journal_div = (By.CLASS_NAME, 'journal-thumbnail-edit-form')
    self._base_admin_journals_edit_logo_upload_btn = (By.CLASS_NAME, 'fileinput-button')
    self._base_admin_journals_logo_upload_note = (By.CLASS_NAME, 'journal-thumbnail-logo-upload-note')
    self._base_admin_journals_edit_title_label = (By.XPATH, '//div[@class="inset-form-control-text"]/label')
    self._base_admin_journals_edit_title_field = (By.XPATH, '//div[@class="inset-form-control required "]/input')
    self._base_admin_journals_edit_desc_label = (By.XPATH, '//div[@class="inset-form-control required "][2]/div/label')
    self._base_admin_journals_edit_desc_field = (By.XPATH, '//div[@class="inset-form-control required "][2]/textarea')
    self._base_admin_journals_edit_cancel_link = (By.CSS_SELECTOR, '//div[@class="journal-edit-buttons"]/a[1]')
    self._base_admin_journals_edit_save_button = (By.CSS_SELECTOR, '//div[@class="journal-edit-buttons"]/a[2]')



    self._base_admin_journals_section_journal_block = (By.CLASS_NAME, 'journal-thumbnail')
    # User Details Overlay
    self._ud_overlay_title = (By.CSS_SELECTOR, 'div.overlay-container div h1')
    self._ud_overlay_closer = (By.CLASS_NAME, 'overlay-close-x')
    self._ud_overlay_uname_label = (By.XPATH, '//div[@class="overlay-container"]/div/div[1]/label')
    self._ud_overlay_uname_field = (By.XPATH, '//div[@class="overlay-container"]/div/div[1]/div/input')
    self._ud_overlay_fname_label = (By.XPATH, '//div[@class="overlay-container"]/div/div[2]/label')
    self._ud_overlay_fname_field = (By.XPATH, '//div[@class="overlay-container"]/div/div[2]/div/input')
    self._ud_overlay_lname_label = (By.XPATH, '//div[@class="overlay-container"]/div/div[3]/label')
    self._ud_overlay_lname_field = (By.XPATH, '//div[@class="overlay-container"]/div/div[3]/div/input')
    self._ud_overlay_reset_pw_btn = (By.CSS_SELECTOR, 'div.reset-password a')
    self._ud_overlay_reset_pw_success_msg = (By.CLASS_NAME, 'success')
    self._ud_overlay_cancel_link = (By.CLASS_NAME, 'cancel-link')
    self._ud_overlay_save_btn = (By.CSS_SELECTOR, 'div.overlay-action-buttons button')

  # POM Actions
  def validate_page_elements_styles_functions(self, username):
    # Validate User section elements
    self._get(self._base_admin_user_search_field)
    self._get(self._base_admin_user_search_button)
    self._get(self._base_admin_user_search_default_state_text)
    # Validate Journals section elements
    self._get(self._base_admin_journals_section_title)
    if username == 'jgray':
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
      assert journal_t in db_journals
      count += 1
