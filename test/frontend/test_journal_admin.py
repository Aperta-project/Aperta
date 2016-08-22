#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_pw, staff_admin_login, super_admin_login
from Pages.admin import AdminPage
from Pages.journal_admin import JournalAdminPage
from frontend.common_test import CommonTest
"""
This test case validates the Aperta Journal-specific Admin page.
"""
__author__ = 'jgray@plos.org'

users = [staff_admin_login,
         super_admin_login,
         ]

user_search = ['apubsvcs', 'areviewer', 'aintedit', 'ahandedit']


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
           - Edit PDF CSS
           - Edit Manuscript CSS
  """
  def test_validate_journal_admin_components_styles(self):
    """
    test_journal_admin: Validate toolbar presentation for journal admin
    Validates the presence of the following elements:
      toolbar elements
      section headings save for user and roles that are validated separately
    """
    logging.info('Validating journal admin component display and function')
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}, {1}'.format(user_type['name'], user_type['email']))
    dashboard_page = self.cas_login(email=user_type['email'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    adm_page.select_random_journal()

    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_nav_toolbar_elements(user_type)

  def test_validate_journal_admin_user_search_display_function(self):
    """
    test_journal_admin: Validate the function of user search in the journal_admin page for a random
      journal
    Validates the presence of the following elements:
      user section heading and user search form elements, user search icon
      result set elements
    """
    logging.info('Validating journal user search display and function')
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}, {1}'.format(user_type['name'], user_type['email']))
    dashboard_page = self.cas_login(email=user_type['email'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    journal = adm_page.select_random_journal()
    logging.info('Journal: {0}'.format(journal))
    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_users_section(journal)

  def test_validate_journal_admin_roles_display_function(self):
    """
    test_journal_admin: validate the display of the admin user role display section
    Validates the presence of the following elements:
      role section heading
      default and non-default role display
      permission display per role
    """
    logging.info('Validating journal role display and function')
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}, {1}'.format(user_type['name'], user_type['email']))
    dashboard_page = self.cas_login(email=user_type['email'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    journal = adm_page.select_random_journal()
    logging.info('Journal: {0}'.format(journal))

    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_roles_section(journal)


  def test_validate_task_types_display_function(self):
    """
    test_journal_admin: validate the display of the journal admin task type section and overlay
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
    logging.info('Logging in as user: {0}, {1}'.format(user_type['name'], user_type['email']))
    dashboard_page = self.cas_login(email=user_type['email'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    journal = adm_page.select_random_journal()
    logging.info('Journal: {0}'.format(journal))
    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_task_types_section(journal)

  def test_validate_mmt_display_function(self):
    """
    test_journal_admin: validate the mmt section display and functions of adding/editing an MMT
    Validates the presence of the following elements:
      Section Heading
      Add new Template button
      Extant MMT display (name and phase number display)
    Validates the function of the:
      Add new Template button
    Validates Editing extant MMT
    :return: void function
    NOTE: Not working due to APERTA-7465
    """
    logging.info('Validating journal mmt (paper type) display and function')
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}, {1}'.format(user_type['name'], user_type['email']))
    dashboard_page = self.cas_login(email=user_type['email'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    adm_page.select_random_journal()

    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_mmt_section()

  def test_validate_add_delete_mmt_function(self):
    """
    test_journal_admin: validate addition and deletion of an MMT from the journal_admin page.
    Validates Add new Template
    Validates Delete new Template
    :return: void function
    NOTE: Not working due to APERTA-7465
    """
    logging.info('Validating journal add mmt (paper type) function')
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}, {1}'.format(user_type['name'], user_type['email']))
    dashboard_page = self.cas_login(email=user_type['email'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    adm_page.select_random_journal()

    ja_page = JournalAdminPage(self.getDriver())
    time.sleep(1)
    ja_page.add_new_mmt_template()
    # This driver reload seems to be the only way to avoid a Stale Reference Exception
    ja_page = JournalAdminPage(self.getDriver())
    time.sleep(1)
    ja_page.delete_new_mmt_template()

  def test_validate_style_settings_display_function(self):
    """
    test_journal_admin: Validate styling & functions of  journal admin page style settings section
    Validates the presence of the following elements:
      Section Heading
      Edit PDF CSS button
      Edit Manuscript CSS button
    Validates the function of the:
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
    logging.info('Logging in as user: {0}, {1}'.format(user_type['name'], user_type['email']))
    dashboard_page = self.cas_login(email=user_type['email'], password=login_valid_pw)
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    adm_page.select_random_journal()

    ja_page = JournalAdminPage(self.getDriver())
    ja_page.validate_style_settings_section()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
