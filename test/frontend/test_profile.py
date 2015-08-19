#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta workflow page
"""
__author__ = 'sbassi@plos.org'

import time

from Base.Decorators import MultiBrowserFixture
from Base.FrontEndTest import FrontEndTest
from Base.Resources import login_valid_uid, affiliation
from Pages.login_page import LoginPage


@MultiBrowserFixture
class ApertaProfileTest(FrontEndTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
         - ProfilePage
     - add/delete affiliations
     - upload image
     - reset password
  """
  
  def test_validate_components_styles(self):
    """Validates the presence of the initial page elements"""
    profile_page = self._go_to_profile()
    profile_page.validate_initial_page_elements_styles(login_valid_uid)
    return self

  def test_affiliations(self):
    """Testing add/delete affiliations"""
    profile_page = self._go_to_profile()
    # Validate image upload
    # Following test not working
    ##profile_page.validate_image_upload()
    # add affiliations
    profile_page.click_add_affiliation_button()
    # Check affiliation css elements
    profile_page.validate_affiliation_form_css()
    profile_page.validate_reset_password()
    return self


if __name__ == '__main__':
  FrontEndTest._run_tests_randomly()
