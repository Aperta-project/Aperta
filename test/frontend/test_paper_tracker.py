#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random

from Pages.dashboard import DashboardPage
from Base.Decorators import MultiBrowserFixture
from frontend.common_test import CommonTest
from Pages.login_page import LoginPage
from Pages.paper_tracker import PaperTrackerPage
from Base.Resources import staff_admin_login, internal_editor_login, pub_svcs_login, \
    super_admin_login

"""
This test case validates the Aperta paper_tracker page.

Note that this case does NOT test actually creating a new manuscript, or accepting or declining an
    invitation
Those acts are expected to be defined in

"""
__author__ = 'jgray@plos.org'


users = [staff_admin_login,
         internal_editor_login,
         pub_svcs_login,
         super_admin_login,
         ]


@MultiBrowserFixture
class ApertaPaperTrackerTest(CommonTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
      - welcome message
      - subhead with paper total presentation
      - presentation of the table
      - presentation of individual data points for each paper
  """
  def test_validate_paper_tracker(self):
    """
    Validates the presence of the following elements:
      Welcome Text, subhead, table presentation
    """
    user_type = random.choice(users)
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.click_paper_tracker_link()

    pt_page = PaperTrackerPage(self.getDriver())
    (total_count, journals_list) = pt_page.validate_heading_and_subhead(user_type['user'])
    logging.info('Total count is {0} for {1}'.format(total_count, journals_list))
    pt_page.validate_table_presentation_and_function(total_count, journals_list)
    pt_page.validate_nav_toolbar_elements(user_type['user'])

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
