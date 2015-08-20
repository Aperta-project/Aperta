#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Journal specific Admin Page. Validates global and dynamic elements and their styles
"""

import random
import time

from selenium.webdriver.common.by import By

from Base.PostgreSQL import PgSQL
from Base.Resources import sa_login
from authenticated_page import AuthenticatedPage
from admin import AdminPage

__author__ = 'jgray@plos.org'


class JournalAdminPage(AdminPage):
  """
  Model an aperta Journal specific Admin page
  """
  def __init__(self, driver, url_suffix='/'):
    super(JournalAdminPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # Journals Admin Page
    self._journal_admin_users_title = (By.CLASS_NAME, 'admin-section-title')
    self._journal_admin_user_search_field = (By.CLASS_NAME, 'admin-user-search-input')
    self._journal_admin_user_search_button = (By.CLASS_NAME, 'admin-user-search-button')
    self._journal_admin_user_search_default_state_text = (By.CLASS_NAME, 'admin-user-search-default-state-text')
    self._journal_admin_user_search_results_table = (By.CLASS_NAME, 'admin-users')
    self._journal_admin_user_search_results_table_uname_header = (By.XPATH, '//table[1]/tr/th[1]')
    self._journal_admin_user_search_results_table_fname_header = (By.XPATH, '//table[1]/tr/th[2]')
    self._journal_admin_user_search_results_table_lname_header = (By.XPATH, '//table[1]/tr/th[3]')
    self._journal_admin_user_search_results_table_rname_header = (By.XPATH, '//table[1]/tr/th[4]')
    self._journal_admin_user_search_results_row = (By.CLASS_NAME, 'user-row')

    self._journal_admin_roles_title = (By.XPATH, '//div[@class="admin-section"][1]/h2')
    self._journal_admin_avail_task_types_title = (By.XPATH, '//div[@class="admin-section"][2]/h2')
    self._journal_admin_manu_mgr_templates_title = (By.XPATH, '//div[@class="admin-section"][3]/h2')
    self._journal_admin_style_settings_title = (By.XPATH, '//div[@class="admin-section"][4]/h2')


  # POM Actions
  def validate_page_elements_styles(self):
    # Validate User section elements
    self.validate_users_section()
    roles_title = self._get(self._journal_admin_roles_title)
    self.validate_application_h2_style(roles_title)
    att_title = self._get(self._journal_admin_avail_task_types_title)
    self.validate_application_h2_style(att_title)
    manu_mgr_title = self._get(self._journal_admin_manu_mgr_templates_title)
    self.validate_application_h2_style(manu_mgr_title)
    style_settings_title = self._get(self._journal_admin_style_settings_title)
    self.validate_application_h2_style(style_settings_title)

  def validate_users_section(self):
    users_title = self._get(self._journal_admin_users_title)
    self.validate_application_h2_style(users_title)
    self._get(self._journal_admin_user_search_field)
    self._get(self._journal_admin_user_search_button)
    self._get(self._journal_admin_user_search_results_table_uname_header)
    self._get(self._journal_admin_user_search_results_table_fname_header)
    self._get(self._journal_admin_user_search_results_table_lname_header)
    self._get(self._journal_admin_user_search_results_table_rname_header)
    self._get(self._journal_admin_user_search_results_table)
    page_user_list = self._gets(self._journal_admin_user_search_results_row)
    print(len(page_user_list))
    for user in page_user_list:
      print(user.text)
      print('\n')
