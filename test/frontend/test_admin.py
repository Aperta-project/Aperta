#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta Admin page.
"""

import logging
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import admin_users, users, external_editorial_users, editorial_users, \
    super_admin_login, billing_staff_login
from .Pages.admin_workflows import AdminWorkflowsPage
from .Pages.admin_users import AdminUsersPage
from .Pages.admin_settings import AdminSettingsPage
from frontend.common_test import CommonTest

__author__ = 'jgray@plos.org'

non_admin_users = users + external_editorial_users + editorial_users
non_admin_users.append(billing_staff_login)
user_search = ['apubsvcs', 'areviewer', 'aintedit', 'ahandedit']
all_users = admin_users + non_admin_users + user_search


@MultiBrowserFixture
class ApertaAdminTest(CommonTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
       - Base Admin page
         - User Search
         - Navigation Menu (changed colors)
         - Title element and Journal links
     Validate journal block display
     Validate Add New Journal
     Validate Edit existing journal
  """
  def test_validate_components_styles(self):
    """
    test_admin: Validate elements and styles for the base Admin page
    :return: void function
    """
    logging.info('Test Admin::validate_components_styles')
    logging.info('Validating Admin page components and styles')
    user_type = random.choice(admin_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.click_admin_link()
    adm_wf_page = AdminWorkflowsPage(self.getDriver())
    adm_wf_page.page_ready()
    adm_wf_page.validate_page_elements_styles(user_type['user'])
    logging.info('Validating journal block display for {0}'.format(user_type['user']))
    adm_wf_page.validate_journal_block_display(user_type['user'])
    adm_wf_page.validate_nav_toolbar_elements(user_type)

  def test_validate_user_search(self):
    """
    test_admin: Validate the function of the base Admin page user search function
    :return: void function
    """
    logging.info('Test Admin::validate_user_search')
    logging.info('Validating base admin page user search function')
    user_type = random.choice(admin_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.click_admin_link()
    adm_users_page = AdminUsersPage(self.getDriver())
    adm_users_page._get(adm_users_page._base_admin_users_link).click()
    adm_users_page.page_ready()
    user = random.choice(user_search)
    logging.info('Searching user: {0}'.format(user))
    adm_users_page.validate_search_edit_user(user, user_type)

  def test_validate_add_new_journal(self):
    """
    test_admin: Validate the elements, styles and process of adding a new journal.
    This test stops short of creating a new journal
    :return: void function
    """
    logging.info('Test Admin::validate_add_new_journal')
    user_type = super_admin_login
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.click_admin_link()
    adm_wf_page = AdminWorkflowsPage(self.getDriver())
    adm_wf_page.page_ready()
    adm_wf_page._get(adm_wf_page._base_admin_add_jrnl_btn).click()
    adm_wf_page.validate_add_new_journal(user_type['user'])

  def test_validate_edit_journal(self):
    """
    test_admin: Validates the edit journal function, form elements and styles.
    :return: void function
    """
    logging.info('Test Admin::validate_edit_journal')
    user_type = super_admin_login
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.click_admin_link()
    adm_settings_page = AdminSettingsPage(self.getDriver())
    adm_settings_page.page_ready()
    adm_settings_page._get(adm_settings_page._base_admin_settings_link).click()
    adm_settings_page.page_ready()
    adm_settings_page.validate_settings_pane('All My Journals')
    journal = adm_settings_page.select_journal(regular=True)
    logging.info(journal)
    # need to click one more time on "Settings", possibly due to APERTA-11068
    adm_settings_page._get(adm_settings_page._base_admin_settings_link).click()
    adm_settings_page.validate_edit_journal(journal)

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
