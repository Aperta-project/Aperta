#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import admin_users, users, external_editorial_users, editorial_users, \
    billing_staff_login
from Pages.base_admin import BaseAdminPage
from Pages.admin_workflows import AdminWorkflowsPage
from Pages.admin_cards import AdminCardsPage
from Pages.admin_users import AdminUsersPage
from Pages.admin_settings import AdminSettingsPage

from frontend.common_test import CommonTest

"""
This test case validates the New Card Config-style Aperta Admin page.
"""

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
    adm_page = BaseAdminPage(self.getDriver())
    adm_page.page_ready()
    adm_page.validate_page_elements_styles(user_type['user'])
    adm_page.validate_nav_toolbar_elements(user_type)
    adm_page.select_admin_top_link('Workflows')
    # Select a random journal link to validate the workflow sub-page
    selected_journal = adm_page.select_journal()
    admin_workflow_pane = AdminWorkflowsPage(self.getDriver())
    admin_workflow_pane.page_ready()
    admin_workflow_pane.validate_workflow_pane(selected_journal)
    # Due to APERTA-9489 Need to manually go back to the admin page
    adm_page.click_admin_link()
    adm_page.select_admin_top_link('Cards')
    # Select a random journal link to validate the cards sub-page
    selected_journal = adm_page.select_journal()
    admin_cards_pane = AdminCardsPage(self.getDriver())
    admin_cards_pane.page_ready()
    admin_cards_pane.validate_cards_pane(selected_journal)
    adm_page.select_admin_top_link('Users')
    # Select a random journal link to validate the Users sub-page
    selected_journal = adm_page.select_journal()
    admin_users_pane = AdminUsersPage(self.getDriver())
    admin_users_pane.page_ready()
    admin_users_pane.validate_users_pane(selected_journal)
    adm_page.select_admin_top_link('Settings')
    # Select a random journal link to validate the Settings sub-page
    selected_journal = adm_page.select_journal()
    admin_settings_pane = AdminSettingsPage(self.getDriver())
    admin_settings_pane.page_ready()
    admin_settings_pane.validate_settings_pane(selected_journal)

  def _test_negative_permission(self):
    """
    test_admin: Validate if non authorized user can see Admin panel
    :return: void function
    """
    # TODO

  # Not yet implemented
  # def test_validate_add_new_journal(self):
  #   """
  #   test_admin: Validate the elements, styles and process of adding a new journal.
  #   This test stops short of creating a new journal
  #   :return: void function
  #   """
  #   logging.info('Test Admin::validate_add_new_journal')
  #   current_path = os.getcwd()
  #   logging.info(current_path)
  #   user_type = super_admin_login
  #   logging.info('Logging in as user: {0}'.format(user_type))
  #   dashboard_page = self.cas_login(email=user_type['email'])
  #   dashboard_page.click_admin_link()
  #   adm_page = BaseAdminPage(self.getDriver())
  #   adm_page.page_ready()
    # Not yet implemented
    # adm_page.validate_add_new_journal(user_type['user'])

  # Not Yet Implemented
  # def test_validate_edit_journal(self):
  #   """
  #   test_admin: Validates the edit journal function, form elements and styles.
  #   :return: void function
  #   """
  #   logging.info('Test Admin::validate_edit_journal')
  #   user_type = super_admin_login
  #   logging.info('Logging in as user: {0}'.format(user_type))
  #   dashboard_page = self.cas_login(email=user_type['email'])
  #   dashboard_page.click_admin_link()
  #   adm_page = AdminPage(self.getDriver())
  #   adm_page.validate_edit_journal(user_type['user'])

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
