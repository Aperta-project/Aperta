#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta Admin page.
"""
__author__ = 'jgray@plos.org'

import logging
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_pw, sa_login, oa_login, au_login, rv_login, ae_login, he_login, fm_login
from Pages.admin import AdminPage
from Pages.dashboard import DashboardPage
from Pages.login_page import LoginPage
from frontend.common_test import CommonTest


users = [oa_login,
         sa_login,
         ]

all_users = [sa_login,
             oa_login,
             au_login,
             rv_login,
             ae_login,
             he_login,
             fm_login,
             ]

user_search = ['OA', 'FM', 'MM', 'RV']

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
    Validates the presence UI elements of base admin page
    """
    logging.info('Validating Admin page components and styles')
    user_type = random.choice(users)
    print('Logging in as user: {}'.format(user_type['user']))
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(user_type['user'])
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    dashboard_page = DashboardPage(self.getDriver())
    dashboard_page.click_admin_link()
    adm_page = AdminPage(self.getDriver())
    adm_page.validate_page_elements_styles(user_type['user'])
    logging.info('Validating journal block display for {0}'.format(user_type['user']))
    adm_page.validate_journal_block_display(user_type['user'])
    adm_page.validate_nav_toolbar_elements(user_type['user'])

  def test_validate_user_search(self):
    """
    Validates the user search function and user details overlay
    """
    logging.info('Validating base admin page user search function')
    user_type = random.choice(users)
    logging.info('Logging in as user: {}'.format(user_type))
    dashboard_page = self.login(email=sa_login['user'], password=login_valid_pw)
    dashboard_page.click_admin_link()
    adm_page = AdminPage(self.getDriver())
    adm_page.validate_search_edit_user(random.choice(user_search))

  def test_validate_add_new_journal(self):
    """
    Validates adding a new journal is available to superadmin
    """
    logging.info('Validating add new journal function')
    user_type = sa_login
    print('Logging in as user: {}'.format(user_type))
    dashboard_page = self.login(email=sa_login['user'], password=login_valid_pw)
    dashboard_page.click_admin_link()
    adm_page = AdminPage(self.getDriver())
    adm_page.validate_add_new_journal(user_type['user'])

  def test_validate_edit_journal(self):
    """
    Validates editing a journal is available to superadmin
    """
    logging.info('Validating edit journal function')
    user_type = sa_login
    print('Logging in as user: {}'.format(user_type))
    dashboard_page = self.login(email=sa_login['user'], password=login_valid_pw)
    dashboard_page.click_admin_link()
    adm_page = AdminPage(self.getDriver())
    adm_page.validate_edit_journal(user_type['user'])

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
