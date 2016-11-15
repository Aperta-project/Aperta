#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case that populates all mmt needed for python test suite runs.
"""

import logging

from Base.Decorators import MultiBrowserFixture
from Base.Resources import super_admin_login

from frontend.common_test import CommonTest

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class ApertaPopulateSuperAdmin(CommonTest):
  """
  Self imposed AC:
     - Populate user and assignment data necessary to run the QA maintained integration test suite
     user list is maintained in Base/Resources.py
  """
  def test_populate_superadmin_assignments(self):
    """
    test_add_superadmin: Getting around a chicken and egg issue. Need the superadmin to bootstrap
      the initial seeding. This test should be run first among test_add_superadmin,
      test_add_stock_mmt and test_add_stock_users_assignments
    :return: void function
    """
    logging.info('test_add_superadmin')
    logging.info('Logging in as user: {0}, {1}'.format(super_admin_login['name'],
                                                       super_admin_login['email']))
    dashboard_page = self.cas_login(email=super_admin_login['email'])
    dashboard_page.page_ready()
    dashboard_page.logout()

    self.set_site_admin_in_db()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
