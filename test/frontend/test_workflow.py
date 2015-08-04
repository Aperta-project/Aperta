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


@MultiBrowserFixture
class ApertaWorkflowTest(FrontEndTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
         - XXXX
         - XXXX
  """
  def _go_to_workflow(self):

    self._select_preexisting_article()
    #self._create_article()
    create_manuscript_page = ManuscriptPage(self.getDriver())
    create_manuscript_page.click_workflow_button()
    return WorkflowPage(self.getDriver())

    return self

  def test_validate_components_styles(self):
    """
    Validates the presence of the following provided elements:
      
    """
    workflow_page = self._go_to_workflow()
    workflow_page.validate_initial_page_elements_styles()
    

    return self



if __name__ == '__main__':
  FrontEndTest._run_tests_randomly()
