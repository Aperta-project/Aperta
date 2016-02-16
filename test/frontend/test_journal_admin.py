#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta Journal-specific Admin page.
"""
__author__ = 'jgray@plos.org'

import logging
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_pw, sa_login, oa_login
from Pages.admin import AdminPage
from Pages.dashboard import DashboardPage
from Pages.journal_admin import JournalAdminPage
from Pages.login_page import LoginPage
from frontend.common_test import CommonTest


users = [oa_login,
         sa_login,
         ]

user_search = ['OA', 'FM', 'MM', 'RV']


@MultiBrowserFixture
class ApertaJournalAdminTest(CommonTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
         # TODO: - Menu Bar
         - User Search  # Minimal coverage
         # TODO: User List and role assignment
         - Role Title, Add Role, Role table, Edit and Delete Roles  # Covering title only
         # TODO: Available Task Types
         # TODO:  Edit Task Types
         # TODO:  Manuscript Manager Templates
         # TODO:  Add Template, Edit Template and Delete Template
         # TODO:  Style Settings
           - Upload Epub Cover
           - Edit Epub CSS
           - Edit PDF CSS
           - Edit Manuscript CSS
  """
  def test_validate_journal_admin_components_styles(self):
    """
    Validates the presence of the following elements:
      toolbar elements
      section headings save for user and roles that are validated separately
    """
    logging.info('Validating journal admin component display and function')
    user_type = random.choice(users)
    print('Logging in as user: {}'.format(user_type))
    dashboard_page = self.login(email=user_type['user'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    adm_page.select_random_journal()

    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_nav_toolbar_elements(user_type['user'])

  def test_validate_journal_admin_user_search_display_function(self):
    """
    Validates the presence of the following elements:
      user section heading and user search form elements, user search icon
      result set elements
    """
    logging.info('Validating journal user search display and function')
    user_type = random.choice(users)
    print('Logging in as user: {}'.format(user_type))
    dashboard_page = self.login(email=user_type['user'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    journal = adm_page.select_random_journal()

    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_users_section(journal)

  def test_validate_journal_admin_roles_display_function(self):
    """
    Validates the presence of the following elements:
      role section heading
      default and non-default role display
      permission display per role
    """
    logging.info('Validating journal role display and function')
    user_type = random.choice(users)
    print('Logging in as user: {}'.format(user_type))
    dashboard_page = self.login(email=user_type['user'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    adm_page.select_random_journal()

    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_roles_section()

  def test_validate_task_types_display_function(self):
    """
    Validates the presence of the following elements:
      Section Heading
      Edit Task Types button
    Validates the function of the:
      Edit task types button
    Validates the elements of the edit task types overlay
      Title
      Closer
      Table display of Title, Role type drop-down selector, clear button
        for all task types
    Validates the function of the edit task types overlay
      manipulating role for task/card type.
    :return: void function
    """
    logging.info('Validating journal task types display and function')
    user_type = random.choice(users)
    print('Logging in as user: {}'.format(user_type))
    dashboard_page = self.login(email=user_type['user'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    adm_page.select_random_journal()

    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_task_types_section()

  def test_validate_mmt_display_function(self):
    """
    Validates the presence of the following elements:
      Section Heading
      Add new Template button
      Extant MMT display (name and phase number display)
    Validates the function of the:
      Add new Template button
    Validates Editing extant MMT
    Validates Deleting extant MMT
    :return: void function
    """
    logging.info('Validating journal mmt (paper type) display and function')
    user_type = random.choice(users)
    print('Logging in as user: {}'.format(user_type))
    dashboard_page = self.login(email=user_type['user'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    journal = adm_page.select_random_journal()

    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_mmt_section()

  def test_validate_style_settings_display_function(self):
    """
    Validates the presence of the following elements:
      Section Heading
      Upload Epub Cover and status text
      Edit EPUB CSS button
      Edit PDF CSS button
      Edit Manuscript CSS button
    Validates the function of the:
      Upload EPUB Cover button
      Edit * CSS buttons
    Validates the elements of the * CSS types overlay
      Title
      Closer
      Field Label
      Textarea
      Cancel link
      Save button
    :return: void function
    """
    logging.info('Validating Journal Style Settings display and function')
    user_type = random.choice(users)
    print('Logging in as user: {}'.format(user_type))
    dashboard_page = self.login(email=user_type['user'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    adm_page.select_random_journal()

    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_style_settings_section()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
