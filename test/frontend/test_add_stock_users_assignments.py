#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case that populates all mmt needed for python test suite runs.
"""

import logging

from Base.Decorators import MultiBrowserFixture
from Base.Resources import all_orcid_users

from frontend.common_test import CommonTest
from .Pages.profile_page import ProfilePage
from .Pages.orcid_login_page import OrcidLoginPage

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class ApertaPopulateUsersTest(CommonTest):
  """
  Self imposed AC:
     - Populate user and assignment data necessary to run the QA maintained integration test suite
     user list is maintained in Base/Resources.py
     This test should be run last among test_add_superadmin (first), test_add_stock_mmt (second) and
    test_add_stock_users_assignments (last).
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
    logging.info('test_add_stock_users_assignments')
    # Ensuring accounts are present for all relevant users
    for user in all_orcid_users:
      logging.info(u'Logging in as user: {0}, {1}'.format(user['name'], user['email']))
      dashboard_page = self.cas_login(email=user['email'])
      dashboard_page.page_ready()
      # Go to the profile page to populate required elements
      dashboard_page.click_profile_link()
      profile_page = ProfilePage(self.getDriver())
      profile_page.page_ready()
      has_orcid = profile_page.has_orcid()
      if not has_orcid:
        profile_page.launch_orcid_window()
        orcid_page = OrcidLoginPage(self.getDriver())
        orcid_page.page_ready()
        orcid_page.validate_orcid_login_elements()
        orcid_page.authorize_user(user)
        orcid_page.clean_orcid_cookies()
      dashboard_page.logout()
    self.set_staff_in_db()
    self.set_freelance_eds_in_db()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
