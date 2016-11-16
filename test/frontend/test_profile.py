#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta profile page
  It needs to validate the elements and styles of the page
  It needs to validate the conditional display of elements as needed for various enabled login types
  It needs to validate the conditional display of elements as needed for various data conditions
  It needs to validate implemented validations for the page
  It needs to validate connect and display of orcid information
  It needs to validate add/edit/delete paths for affiliations
"""

import logging
import os

from Base.Decorators import MultiBrowserFixture
from frontend.common_test import CommonTest
from frontend.Pages.profile_page import ProfilePage

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
    profile_page.validate_add_affiliation_validations(profile_user)
    profile_page.validate_nav_toolbar_elements(profile_user)

  def test_affiliations(self):
    """
    test_profile: validate implemented validations for add affiliation
                  validate add new affiliation
                  validate edit existing affiliation
                  validate delete existing affiliation
    :return: void function
    """
    logging.info('Test Profile::affiliations')
    current_path = os.getcwd()
    logging.info(current_path)
    profile_user = self.select_cas_user()
    logging.info(profile_user)
    dashboard = self.cas_login(email=profile_user['email'])
    dashboard.page_ready()
    dashboard.click_profile_link()
    profile_page = ProfilePage(self.getDriver())
    profile_page.page_ready()
    # Validate image upload
    profile_page.validate_image_upload(profile_user)
    # add affiliations
    profile_page.click_add_affiliation_button()
    profile_page.add_affiliation_cancel()
    profile_page.click_add_affiliation_button()
    new_affiliation = profile_page.add_affiliation(profile_user)
    profile_page.validate_affilation(new_affiliation)
    edited_affiliation = profile_page.edit_affiliation(profile_user)
    profile_page.validate_affiliation(edited_affiliation)
    profile_page.delete_affiliation(profile_user)
    profile_page.validate_no_affiliation()


  def test_orcid(self):
    """
    test_profile: validate adding an orcid connection
                  validate linking and oath process
                  validate delete existing orcid connection
    :return: void function
    """
    logging.info('Test Profile::orcid')
    current_path = os.getcwd()
    logging.info(current_path)
    profile_user = self.select_cas_user()
    logging.info(profile_user)
    dashboard = self.cas_login(email=profile_user['email'])
    dashboard.page_ready()
    dashboard.click_profile_link()
    profile_page = ProfilePage(self.getDriver())
    profile_page.page_ready()
    # TODO: Implement the ORCID tests
    # TODO: Linking by Registering New
    # TODO: Linking by authorizing against existing ORCID
    # TODO: Deleting existing linkage


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
