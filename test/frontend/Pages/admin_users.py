#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the base Admin Page, Users Tab. Validates elements and their styles,
and functions.
"""
import logging
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.PostgreSQL import PgSQL

from .base_admin import BaseAdminPage

__author__ = 'jgray@plos.org'


class AdminUsersPage(BaseAdminPage):
  """
  Model the common base Admin page, users Tab elements and their functions
  """
  def __init__(self, driver):
    super(AdminUsersPage, self).__init__(driver)

    # Locators - Instance members
    self._admin_users_pane_title = (By.CSS_SELECTOR, 'div.admin-page-content > div > h2')
    self._admin_users_search_field = (By.CSS_SELECTOR, 'div.admin-user-search > input')
    self._admin_users_search_button = (By.CSS_SELECTOR, 'div.admin-user-search > button')
    self._admin_users_default_state_text = (By.CSS_SELECTOR,
                                            '.admin-user-search-default-state-text')
    self._admin_users_search_results_table = (By.CLASS_NAME, 'admin-users-list-list')
    self._admin_users_search_results_table_lname_header = (By.XPATH, '//table[1]/tr/th[1]')
    self._admin_users_search_results_table_fname_header = (By.XPATH, '//table[1]/tr/th[2]')
    self._admin_users_search_results_table_uname_header = (By.XPATH, '//table[1]/tr/th[3]')
    self._admin_users_search_results_table_rname_header = (By.XPATH, '//table[1]/tr/th[4]')
    self._admin_users_search_results_row = (By.CLASS_NAME, 'user-row')

    self._admin_users_row_lname = (By.CSS_SELECTOR, 'tr.user-row td')
    self._admin_users_row_fname = (By.CSS_SELECTOR, 'tr.user-row td + td')
    self._admin_users_row_username = (By.CSS_SELECTOR, 'tr.user-row td + td + td')
    self._admin_users_row_roles = (By.CSS_SELECTOR,
                                          'tr.user-row td div ul.select2-choices li div')
    self._admin_users_row_role_delete = (By.CSS_SELECTOR,
                                                'tr.user-row td div ul.select2-choices li a')
    self._admin_users_row_role_add = (By.CSS_SELECTOR, 'tr.user-row td div span.assign-role-button')
    self._admin_users_row_role_add_field = (
        By.CSS_SELECTOR, 'tr.user-row td div div ul li.select2-search-field input')
    self._admin_users_row_role_search_result_item = (By. CSS_SELECTOR, 'ul.select2-results li div')
    # User Detail Overlay items
    self._ud_overlay_title = (By.CLASS_NAME, 'overlay-header-title')
    self._ud_overlay_uname_label = (By.XPATH, '//label[contains(@for, \'user-detail-username\')]')
    self._ud_overlay_uname_field = (By.ID, 'user-detail-username')
    self._ud_overlay_fname_label = (By.XPATH, '//label[contains(@for, \'user-detail-first-name\')]')
    self._ud_overlay_fname_field = (By.ID, 'user-detail-first-name')
    self._ud_overlay_lname_label = (By.XPATH, '//label[contains(@for, \'user-detail-last-name\')]')
    self._ud_overlay_lname_field = (By.ID, 'user-detail-last-name')
    self._ud_overlay_cancel_link = (By.CLASS_NAME, 'cancel-link')
    self._ud_overlay_save_button = (By.CSS_SELECTOR, 'div.overlay-action-buttons > button')

  # POM Actions
  def page_ready(self):
    """"Ensure the page is ready to test"""
    self._admin_users_search_field = (By.CSS_SELECTOR, 'div.admin-user-search > input')
    self._wait_for_element(self._get(self._admin_users_search_field))

  def validate_users_pane(self, selected_jrnl):
    """
    Assert the existence and function of the elements of the Users pane.
    Validate Add new template, edit/delete existing templates, validate presentation.
    :param selected_jrnl: The name of the selected journal for which to validate the workflow pane
    :return: void function
    """
    # Time to fully populate Users with Roles display for selected journal
    time.sleep(1)
    all_journals = False
    # APERTA-9498
    # users_title = self._get(self._admin_users_pane_title)
    # self.validate_application_h2_style(users_title)
    journal_id = PgSQL().query('SELECT id FROM journals WHERE name = %s;', (selected_jrnl,))[0][0]
    logging.debug(journal_id)
    journal_roles = PgSQL().query('SELECT id from roles WHERE journal_id = %s AND name in '
                                  '(\'Staff Admin\', \'Internal Editor\', \'Production Staff\','
                                  '\'Publishing Services\', \'Freelance Editors\','
                                  '\'Journal Setup Admin\');', (journal_id,))
    journal_roles = tuple([x[0] for x in journal_roles])
    users_db = PgSQL().query('SELECT user_id from assignments WHERE role_id in %s AND '
                             'assigned_to_id = %s AND assigned_to_type=\'Journal\';',
                             (journal_roles, journal_id))
    users_db = set([x[0] for x in users_db])
    self._get(self._admin_users_search_field)
    self._get(self._admin_users_search_button)
    if users_db:
      self._get(self._admin_users_search_results_table_uname_header)
      self._get(self._admin_users_search_results_table_fname_header)
      self._get(self._admin_users_search_results_table_lname_header)
      self._get(self._admin_users_search_results_table_rname_header)
      self._get(self._admin_users_search_results_table)
      self._gets(self._admin_users_search_results_row)
    else:
      logging.info('No users assigned roles in journal: {0}, '
                   'so will add one...'.format(selected_jrnl))
      self._add_user_with_role('atest author3', 'Staff Admin')
      logging.info('Verifying added user')
      # APERTA-9500
      # self._validate_user_with_role('atest author3', 'Staff Admin')
      logging.info('Deleting newly added user')
      self._delete_user_with_role()

  def _add_user_with_role(self, user, role):
    """
    For user and role names, add to current journal
    :param user: existing user
    :param role: existing role
    :return: void function
    """
    user_input = self._get(self._admin_users_search_field)
    search_btn = self._get(self._admin_users_search_button)
    user_input.clear()
    self._actions.send_keys_to_element(user_input, user).perform()
    search_btn.click()
    self._get(self._admin_users_row_role_add).click()
    role_search_field = self._get(self._admin_users_row_role_add_field)
    self._actions.send_keys_to_element(role_search_field, role + Keys.RETURN).perform()

  def _validate_user_with_role(self, user, role):
    """
    For named user and role, ensure this exists for current journal
    :param user: user to validate
    :param role: role to validate
    :return: void function
    """
    page_user_list = self._gets(self._admin_users_search_results_row)
    for row in page_user_list:
      assert user in row.text, row.text
      assert role in row.text, row.text

  def _delete_user_with_role(self):
    """
    Delete user role
    :return: void function
    """
    user_role_pill = self._get(self._admin_users_row_roles)
    # For whatever reason, using action chains move_to_element() is failing here
    # so doing a simple click
    user_role_pill.click()
    delete_role = self._get(self._admin_users_row_role_delete)
    delete_role.click()

  def validate_search_edit_user(self, username, searcher):
    """
    Validates the styling and output of the base admin user search
    :param username: A username against which to search
    :param searcher: The username conducting the search
    :return: void function
    """
    time.sleep(1)  # sadly one needs to allow time for the result set to update from the server
    # This search result only shows for the all my journals selection which is only the default selection for a site
    #   admin
    if searcher == 'asuperadm':
      no_result_search_text = self._get(self._admin_users_default_state_text).text
      assert no_result_search_text == 'No matching users found'
    self._search_user(username)
    self._get(self._admin_users_search_results_table)
    self._get(self._admin_users_search_results_table_fname_header)
    self._get(self._admin_users_search_results_table_lname_header)
    self._get(self._admin_users_search_results_table_uname_header)
    # TODO: Determine the search heuristic and enforce it. It seems overly broad currently.
    result_set = self._gets(self._admin_users_search_results_row)
    success_count = 0
    for result in result_set:
      if username in result.text:
        success_count += 1
        result_username = result.find_element(*self._admin_users_row_username)
        logging.info('Clicking result set row for user {0}'.format(result_username.text))
        result_username.click()
        time.sleep(4) #bumping sleep per failure here: https://teamcity.plos.org/teamcity/viewLog.html?buildId=138228&tab=buildResultsDiv&buildTypeId=Aperta_NoNoseIntegrationTestOnSfoRc
        self._get(self._ud_overlay_title)
        user_details_closer = self._get(self._overlay_header_close)
        self._get(self._ud_overlay_fname_label)
        self._get(self._ud_overlay_fname_field)
        self._get(self._ud_overlay_lname_label)
        self._get(self._ud_overlay_lname_field)
        self._get(self._ud_overlay_uname_label)
        self._get(self._ud_overlay_uname_field)
        self._get(self._ud_overlay_cancel_link)
        self._get(self._ud_overlay_save_button)
        user_details_closer.click()
    assert success_count > 0

  def _search_user(self, username):
    """
    provided a username, executes the search for that username
    :param username: a string to search for
    :return: void function
    """
    user_search_field = self._get(self._admin_users_search_field)
    user_search_btn = self._get(self._admin_users_search_button)
    user_search_field.clear()
    user_search_field.send_keys(username)
    user_search_btn.click()

# TODO: When available, test opening the user detail overlay see APERTA-9499
