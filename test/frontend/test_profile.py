#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta workflow page
"""
__author__ = 'sbassi@plos.org'

import time

from Base.Decorators import MultiBrowserFixture
from Base.FrontEndTest import FrontEndTest
from Base.Resources import login_valid_uid
from Pages.login_page import LoginPage


@MultiBrowserFixture
class ApertaProfileTest(FrontEndTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
         - ProfilePage
  """
  
  def test_validate_components_styles(self):
    """Validates the presence of the initial page elements"""
    profile_page = self._go_to_profile()
    profile_page.validate_initial_page_elements_styles(login_valid_uid)
    return self

  def _test_add_new_card(self):
    """Testing adding a new card"""
    workflow_page = self._go_to_workflow()
    # GET URL
    time.sleep(2)
    #driver = self.getDriver()
    workflow_url = self._driver.current_url
    # Count cards in first column
    start_cards = workflow_page.count_cards_first_column()
    # Test add new card
    workflow_page.click_add_new_card()
    # Elements in add new card
    workflow_page.check_overlay()
    workflow_page.check_new_tasks_overlay()
    # Going to workflow from scrach to avoid using card elements
    self._driver.get(workflow_url)
    time.sleep(2)
    current_cards = workflow_page.count_cards_first_column()
    # Check that there is one more card after adding a card
    assert start_cards + 1 == current_cards
    # NOTE: Missing deleting a new card
    return self


if __name__ == '__main__':
  FrontEndTest._run_tests_randomly()
