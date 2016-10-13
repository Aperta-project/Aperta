#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case that populates all mmt needed for python test suite runs.
"""

import logging

from Base.Decorators import MultiBrowserFixture
from Base.Resources import reviewer_login, staff_admin_login, handling_editor_login, \
    pub_svcs_login, academic_editor_login, internal_editor_login, super_admin_login, \
    cover_editor_login, prod_staff_login, billing_staff_login

from frontend.common_test import CommonTest

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class ApertaPopulateUsersTest(CommonTest):
  """
  Self imposed AC:
     - Populate user and assignment data necessary to run the QA maintained integration test suite
     user list is maintained in Base/Resources.py
  """
  def test_populate_base_users_assignments(self):
    """
    test_add_stock_users_assignments: adds the stock users via forcing logins and then sets the
      appropriate assignments for those users.
    reviewer_login, staff_admin_login, handling_editor_login, pub_svcs_login, academic_editor_login,
     internal_editor_login, super_admin_login, cover_editor_login, prod_staff_login,
     billing_staff_login
    :return: void function
    """
    all_users = [reviewer_login, staff_admin_login, handling_editor_login, pub_svcs_login,
                 academic_editor_login, internal_editor_login, super_admin_login,
                 cover_editor_login, prod_staff_login, billing_staff_login]
    logging.info('test_add_stock_users_assignments')
    # Ensuring accounts are present for all relevant users
    for user in all_users:
      logging.info('Logging in as user: {0}, {1}'.format(user['name'], user['email']))
      dashboard_page = self.cas_login(email=user['email'])
      dashboard_page._wait_for_page_load()
      dashboard_page.logout()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
