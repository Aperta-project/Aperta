#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time
import logging

from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_uid, super_admin_login
from frontend.common_test import CommonTest
from frontend.Pages.profile_page import ProfilePage
from Pages.dashboard import DashboardPage

"""
This test case validates the Aperta workflow page
"""

__author__ = 'sbassi@plos.org'


@MultiBrowserFixture
class ApertaProfileTest(CommonTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
         - ProfilePage
     - add/delete affiliations
     - upload image
     - reset password
  """

  def _go_to_profile(self, init=True):
    """Go to the profile page"""
    # APERTA-6146 Can only use super admin login for the time being.
    dashboard = self.cas_login(email=super_admin_login['email']) if init \
        else DashboardPage(self.getDriver())
    dashboard.click_profile_link()
    return ProfilePage(self.getDriver())

  def test_validate_components_styles(self):
    """
    test_profile: Validates elements and styles of the profile page
    :return: void function
    """
    profile_page = self._go_to_profile()
    profile_page.validate_initial_page_elements_styles(login_valid_uid)
    profile_page.validate_invalid_add_new_affiliation()
    return self

  def test_affiliations(self):
    """
    test_profile: Validates function of adding/deleting affiliations
    :return: void function
    """
    profile_page = self._go_to_profile()
    # Validate image upload
    profile_page.validate_image_upload()
    # add affiliations
    profile_page.click_add_affiliation_button()
    # Check affiliation css elements
    profile_page.validate_affiliation_form_css()
    return self

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
