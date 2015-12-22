#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Journal specific Admin Page. Validates global and dynamic elements and their styles
This is really a shell of a test. It minimally validates the page elements, and not yet any of their functions.
We can extend this at a later time.
"""

import logging
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.PostgreSQL import PgSQL
from Base.CustomException import ElementDoesNotExistAssertionError
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

    self._journal_admin_user_row_username = (By.CSS_SELECTOR, 'tr.user-row td')
    self._journal_admin_user_row_fname = (By.CSS_SELECTOR, 'tr.user-row td + td')
    self._journal_admin_user_row_lname = (By.CSS_SELECTOR, 'tr.user-row td + td + td')
    self._journal_admin_user_row_roles = (By.CSS_SELECTOR, 'tr.user-row td div ul.select2-choices li div')
    self._journal_admin_user_row_role_delete = (By.CSS_SELECTOR, 'tr.user-row td div ul.select2-choices li a')
    self._journal_admin_user_row_role_add = (By.CSS_SELECTOR, 'tr.user-row td div span.assign-role-button')
    self._journal_admin_user_row_role_add_field = (By.CSS_SELECTOR,
                                                   'tr.user-row td div div ul li.select2-search-field input')
    self._journal_admin_user_row_role_search_result_item = (By. CSS_SELECTOR, 'ul.select2-results li div')


    self._journal_admin_roles_title = (By.XPATH, '//div[@class="admin-section"][1]/h2')
    self._journal_admin_roles_add_new_role_btn = (By.CSS_SELECTOR, 'div.admin-section button')
    self._journal_admin_roles_role_table = (By.CLASS_NAME, 'admin-roles')
    self._journal_admin_roles_role_name_heading = (By.CSS_SELECTOR, 'div.admin-roles div.admin-roles-header')
    self._journal_admin_roles_permission_heading = (By.CSS_SELECTOR,
                                                    'div.admin-roles div.admin-roles-header + div.admin-roles-header')
    self._journal_admin_roles_role_listing_row = (By.CSS_SELECTOR, 'div.admin-roles div.admin-role')


    self._journal_admin_avail_task_types_title = (By.XPATH, '//div[@class="admin-section"][2]/h2')
    self._journal_admin_manu_mgr_templates_title = (By.XPATH, '//div[@class="admin-section"][3]/h2')
    self._journal_admin_style_settings_title = (By.XPATH, '//div[@class="admin-section"][4]/h2')

  # POM Actions
  def validate_page_elements_styles(self):
    att_title = self._get(self._journal_admin_avail_task_types_title)
    self.validate_application_h2_style(att_title)
    manu_mgr_title = self._get(self._journal_admin_manu_mgr_templates_title)
    self.validate_application_h2_style(manu_mgr_title)
    style_settings_title = self._get(self._journal_admin_style_settings_title)
    self.validate_application_h2_style(style_settings_title)

  def validate_users_section(self, journal):
    users_title = self._get(self._journal_admin_users_title)
    self.validate_application_h2_style(users_title)
    jid = PgSQL().query('SELECT id FROM journals WHERE name = %s;', (journal,))[0][0]
    logging.debug(jid)
    role_list = PgSQL().query('SELECT * FROM roles WHERE journal_id = %s;', (jid,)) or []
    logging.debug(role_list)
    roles_count = 0
    for role in role_list:
      rcount = PgSQL().query('SELECT count(user_id) from user_roles WHERE role_id in (%s);', (role[0],))[0][0]
      roles_count = roles_count + rcount
    logging.debug(roles_count)
    self._get(self._journal_admin_user_search_field)
    self._get(self._journal_admin_user_search_button)
    if roles_count > 0:
      self._get(self._journal_admin_user_search_results_table_uname_header)
      self._get(self._journal_admin_user_search_results_table_fname_header)
      self._get(self._journal_admin_user_search_results_table_lname_header)
      self._get(self._journal_admin_user_search_results_table_rname_header)
      self._get(self._journal_admin_user_search_results_table)
      page_user_list = self._gets(self._journal_admin_user_search_results_row)
      for user in page_user_list:
        print(user.text)
        print('\n')
    else:
      logging.info('No users assigned roles in journal: {}, so will add one...'.format(journal))
      self._add_user_with_role('jgray_author', 'Flow Manager')
      logging.info('Verifying added user')
      self._validate_user_with_role('jgray_author', 'Flow Manager')
      logging.info('Deleting newly added user')
      self._delete_user_with_role('jgray_author', 'Flow Manager')
      time.sleep(3)

  def _add_user_with_role(self, user, role):
    user_title = self._get(self._journal_admin_users_title)
    self._actions.move_to_element(user_title).perform()
    user_input = self._get(self._journal_admin_user_search_field)
    search_btn = self._get(self._journal_admin_user_search_button)
    user_input.clear()
    self._actions.send_keys_to_element(user_input, user).perform()
    search_btn.click()
    self._get(self._journal_admin_user_row_role_add).click()
    role_search_field = self._get(self._journal_admin_user_row_role_add_field)
    self._actions.send_keys_to_element(role_search_field, role + Keys.RETURN).perform()

  def _validate_user_with_role(self, user, role):
    page_user_list = self._gets(self._journal_admin_user_search_results_row)
    for row in page_user_list:
      assert user in row.text, row.text
      assert role in row.text, row.text

  def _delete_user_with_role(self, user, role):
    user_role_pill = self._get(self._journal_admin_user_row_roles)
    # For whatever reason, using action chains move_to_element() is failing here so doing a simple click
    user_role_pill.click()
    delete_role = self._get(self._journal_admin_user_row_role_delete)
    delete_role.click()

  def validate_roles_section(self):
    roles_title = self._get(self._journal_admin_roles_title)
    self._actions.move_to_element(roles_title).perform()
    self.validate_application_h2_style(roles_title)
    self._get(self._journal_admin_roles_add_new_role_btn)
    self._get(self._journal_admin_roles_role_table)
    role_rows = self._gets(self._journal_admin_roles_role_listing_row)
    count = 1
    for row in role_rows:
      logging.info(row.text)
      self._role_edit_icon = \
          (By.XPATH,
           "//div[@class='ember-view admin-role not-editing'][{}]\
              /div/i[@class='admin-role-action-button fa fa-pencil']".format(count))
      self._get(self._role_edit_icon)
      self._role_name = (By.XPATH, "//div[@class='ember-view admin-role not-editing'][{}]\
          /div/span".format(count))
      role_name = self._get(self._role_name)
      if role_name.text not in ('Admin', 'Flow Manager', 'Editor'):
        self._role_delete_icon = (By.XPATH,
           "//div[@class='ember-view admin-role not-editing'][{}]\
              /div/i[@class='admin-role-action-button role-delete-button fa fa-trash']".format(count))
        delete_role = self._get(self._role_delete_icon)
      self._role_permissions_div = (By.XPATH, "//div[@class='ember-view admin-role not-editing'][{}]\
           /div[@class='admin-role-permissions']".format(count))
      self._get(self._role_permissions_div)
      self._role_assigned_permission = (By.XPATH, "//div[@class='ember-view admin-role not-editing'][{}]\
          /div[@class='admin-role-permissions']/label".format(count))
      self.set_timeout(1)
      try:
        permissions = self._gets(self._role_assigned_permission)
        # print(permissions)
      except ElementDoesNotExistAssertionError:
        logging.warning('No permissions found for role {}'.format(role_name.text))
      try:
        role_perms = self._get(self._role_permissions_div).find_elements(*self._role_assigned_permission)
        # print(role_perms.text)
        # for role in role_perms:
          # print(role.text)
      except ElementDoesNotExistAssertionError:
        logging.warning('No permissions found for role: {}'.format(role_name.text))
      self.restore_timeout()
      count += 1