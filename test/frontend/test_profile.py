#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import logging
import os

from Base.Decorators import MultiBrowserFixture
from frontend.common_test import CommonTest
from frontend.Pages.profile_page import ProfilePage

"""
This test case validates the Aperta profile page
"""

__author__ = 'sbassi@plos.org'


@MultiBrowserFixture
class ApertaProfileTest(CommonTest):
  """
  AC:
     - validate page elements and styles for:
         - ProfilePage
     - add/delete affiliations
     - edit affiliations
     - upload image
     - reset password
  """

  def test_validate_components_styles(self):
    """
    test_profile: Validates elements and styles of the profile page
    :return: void function
    """
    logging.info('Test Profile::components_styles')
    current_path = os.getcwd()
    logging.info(current_path)
    profile_user = self.select_cas_user()
    logging.info(profile_user)
    dashboard = self.cas_login(email=profile_user['email'])
    dashboard.page_ready()
    dashboard.click_profile_link()
    profile_page = ProfilePage(self.getDriver())
    profile_page.page_ready()
    profile_page.validate_initial_page_elements_styles(profile_user)
    profile_page.validate_invalid_add_new_affiliation()
    profile_page.validate_nav_toolbar_elements(profile_user)

  def test_affiliations(self):
    """
    test_profile: Validates function of adding/deleting affiliations
    :return: void function
    """
    logging.info('Test Profile::affiliations')
    current_path = os.getcwd()
    logging.info(current_path)
    dashboard = self.cas_login()
    dashboard.page_ready()
    dashboard.click_profile_link()
    profile_page = ProfilePage(self.getDriver())
    profile_page.page_ready()
    # Validate image upload
    profile_page.validate_image_upload()
    # add affiliations
    profile_page.click_add_affiliation_button()
    # Check affiliation css elements
    profile_page.validate_affiliation_form_css()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
