#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time
import logging

from Base.Decorators import MultiBrowserFixture
from frontend.common_test import CommonTest
from frontend.Pages.profile_page import ProfilePage

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

  def test_validate_components_styles(self):
    """
    test_profile: Validates elements and styles of the profile page
    :return: void function
    """
    profile_user = self.select_cas_user()
    dashboard = self.cas_login(email=profile_user['email'])
    dashboard.click_profile_link()
    profile_page = ProfilePage(self.getDriver())
    profile_page.validate_initial_page_elements_styles(profile_user)
    profile_page.validate_invalid_add_new_affiliation()
    profile_page.validate_nav_toolbar_elements(profile_user)
    return self

  def test_affiliations(self):
    """
    test_profile: Validates function of adding/deleting affiliations
    :return: void function
    """
    dashboard = self.cas_login()
    dashboard.click_profile_link()
    profile_page = ProfilePage(self.getDriver())
    # Validate image upload
    profile_page.validate_image_upload()
    # add affiliations
    profile_page.click_add_affiliation_button()
    # Check affiliation css elements
    profile_page.validate_affiliation_form_css()
    return self

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
