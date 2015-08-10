#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta workflow page
"""
__author__ = 'sbassi@plos.org'

from Base.Decorators import MultiBrowserFixture
from Base.FrontEndTest import FrontEndTest
from Pages.login_page import LoginPage
from Base.Resources import login_valid_email, login_valid_pw
from frontend.Pages.manuscript_page import ManuscriptPage
from frontend.Pages.workflow_page import WorkflowPage
import time

@MultiBrowserFixture
class ApertaWorkflowTest(FrontEndTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
         - WorkflowPage
         - Adding cards
         - Removing cards (NOT READY)
  """
  def _go_to_workflow(self):
    """Internal method to reach workflow page"""
    self._select_preexisting_article()
    #self._create_article()
    create_manuscript_page = ManuscriptPage(self.getDriver())
    create_manuscript_page.click_workflow_button()
    return WorkflowPage(self.getDriver())

  def test_validate_components_styles(self):
    """
    Validates the presence of the initial page elements      
    """
    workflow_page = self._go_to_workflow()
    workflow_page.validate_initial_page_elements_styles()
    return self

  def test_headers(self):
    """Test headers of columns in Workflow"""
    workflow_page = self._go_to_workflow()
    # check for cancel edit
    original_header_text = workflow_page.click_column_header()
    # modify
    workflow_page.modify_column_header('XX', blank=False)
    time.sleep(1)
    header_text = workflow_page.click_column_header()
    assert 'XX' in header_text
    # restore original value
    workflow_page.modify_column_header(original_header_text)
    # Test cancel button
    header_text = workflow_page.click_column_header()
    workflow_page.click_cancel_column_header()
    return self

  def test_add_new_card(self):
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
