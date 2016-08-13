#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import staff_admin_login, super_admin_login, creator_login1, \
    creator_login2, creator_login3, creator_login4, creator_login5, reviewer_login, \
    academic_editor_login, handling_editor_login, cover_editor_login, internal_editor_login, \
    pub_svcs_login
from Pages.admin import AdminPage
from frontend.common_test import CommonTest

"""
This test case validates the Aperta Admin page.
"""

__author__ = 'jgray@plos.org'

admin_users = [staff_admin_login, super_admin_login]
non_admin_users = [creator_login1, creator_login2, creator_login3, creator_login4,
                   creator_login5, reviewer_login, academic_editor_login, handling_editor_login,
                   cover_editor_login, internal_editor_login, pub_svcs_login]
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
    logging.info('Validating Admin page components and styles')
    user_type = random.choice(admin_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.click_admin_link()
    adm_page = AdminPage(self.getDriver())
    adm_page.validate_page_elements_styles(user_type['user'])
    logging.info('Validating journal block display for {0}'.format(user_type['user']))
    adm_page.validate_journal_block_display(user_type['user'])
    adm_page.validate_nav_toolbar_elements(user_type)

  def _test_negative_permission(self):
    """
    test_admin: Validate if non authorized user can see Admin panel
    :return: void function
    """
    # TODO

  def test_validate_user_search(self):
    """
    test_admin: Validate the function of the base Admin page user search function
    :return: void function
    """
    logging.info('Validating base admin page user search function')
    user_type = random.choice(admin_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.click_admin_link()
    adm_page = AdminPage(self.getDriver())
    # TODO: Validate following case with other users
    user = random.choice(user_search)
    logging.info('Searching user: {0}'.format(user))
    adm_page.validate_search_edit_user(user)


  def test_validate_add_new_journal(self):
    """
    test_admin: Validate the elements, styles and process of adding a new journal.
    This test stops short of creating a new journal
    :return: void function
    """
    logging.info('Validating add new journal function')
    user_type = super_admin_login
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.click_admin_link()
    adm_page = AdminPage(self.getDriver())
    adm_page.validate_add_new_journal(user_type['user'])

  def test_validate_edit_journal(self):
    """
    test_admin: Validates the edit journal function, form elements and styles.
    :return: void function
    """
    logging.info('Validating edit journal function')
    user_type = super_admin_login
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.click_admin_link()
    adm_page = AdminPage(self.getDriver())
    adm_page.validate_edit_journal(user_type['user'])

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
