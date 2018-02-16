#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta paper_tracker page.

Note that this case does NOT test actually creating a new manuscript, or accepting or declining an
    invitation
Those acts are expected to be defined in

"""

import logging
import os
import random

from Base.Decorators import MultiBrowserFixture
from frontend.common_test import CommonTest
from .Pages.paper_tracker import PaperTrackerPage
from Base.Resources import editorial_users

__author__ = 'jgray@plos.org'

users = editorial_users


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
        test_paper_tracker: Validate elements, styles of the paper tracker page
        Validates the presence of the following elements:
          Welcome Text, subhead, table presentation
        """
        logging.info('Test Paper Tracker:: components_styles')
        current_path = os.getcwd()
        logging.info(current_path)
        user_type = random.choice(users)
        dashboard_page = self.cas_login(email=user_type['email'])
        dashboard_page.click_paper_tracker_link()

        pt_page = PaperTrackerPage(self.getDriver())
        pt_page.validate_pagination(user_type['user'])
        pt_page.validate_nav_toolbar_elements(user_type)

    def test_validate_paper_tracker_table_content(self):
        """
        test_paper_tracker: Validate the contents of the dynamic table
        """
        logging.info('Test Paper Tracker::table_content')
        current_path = os.getcwd()
        logging.info(current_path)
        user_type = random.choice(users)
        dashboard_page = self.cas_login(email=user_type['email'])
        dashboard_page.click_paper_tracker_link()
        pt_page = PaperTrackerPage(self.getDriver())
        (total_count, journals_list) = pt_page.get_paper_count_per_user(user_type['user'])
        logging.info('Total count is {0} for {1}'.format(total_count, journals_list))
        pt_page.validate_table_presentation_and_function(total_count, journals_list, user_type)

    def test_validate_paper_tracker_search(self):
        """
        test_paper_tracker: Validate Paper tracker search and saved search functions
        Validate the Aperta Query Language Usage, Search function elements, including saved search,
         and the Saved Search functions
        """
        logging.info('Test Paper Tracker::search')
        current_path = os.getcwd()
        logging.info(current_path)
        user_type = random.choice(users)
        dashboard_page = self.cas_login(email=user_type['email'])
        dashboard_page.click_paper_tracker_link()

        pt_page = PaperTrackerPage(self.getDriver())
        pt_page.validate_search_execution()


if __name__ == '__main__':
    CommonTest.run_tests_randomly()
