#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users, external_editorial_users
from frontend.common_test import CommonTest

"""
This test case validates the Aperta dashboard page and its associated View Invitations and Create
  New Submission overlays.

Note that this case does NOT test actually creating a new manuscript, or accepting or declining an
  invitation
"""

__author__ = 'jgray@plos.org'

all_users = [users + editorial_users + external_editorial_users]


@MultiBrowserFixture
class ApertaDashboardTest(CommonTest):
  """
  AC:
     - validate page elements and styles for:
         - dashboard page:
            - Optional Invitation elements
              - title, buttons
            - Submissions section
              - title, button, manuscript details
         - view invitations modal dialog elements and function
         - create new submission modal dialog and function
          - validate ordering of mmt per journal
  """
  def test_smoke_validate_components_styles(self):
    """
    test_dashboard: Validates element presentation and styles for dashboard and associated modals
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission
    """
    user_type = random.choice(users)
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.validate_mmt_ordering()
    dashboard_page.validate_initial_page_elements_styles()
    dashboard_page.validate_invite_dynamic_content(user_type)
    (active_manuscript_count, active_manuscript_list, uid) = \
        dashboard_page.validate_manuscript_section_main_title(user_type)
    logging.debug('Active manuscript count is: {0}'.format(active_manuscript_count))
    if active_manuscript_count > 0:
      dashboard_page.validate_active_manuscript_section(uid,
                                                        active_manuscript_count,
                                                        active_manuscript_list)
    (inactive_manuscript_count, inactive_manuscript_list) = \
        dashboard_page.validate_inactive_manuscript_section(uid)
    if active_manuscript_count == 0 and inactive_manuscript_count == 0:
      dashboard_page.validate_no_manus_info_msg()
    # The dashboard navigation elements will change based on a users permissions
    # Author gets Close, Title, Profile Link with Image, Dashboard Link, Signout Link, separator,
    #   Feedback Link
    dashboard_page.validate_nav_toolbar_elements(user_type)

    # Validate View Invites modal (optional)
    invites = dashboard_page.is_invite_stanza_present(user_type)
    if invites > 0:
      dashboard_page.click_view_invites_button()
      dashboard_page.validate_view_invites(user_type['user'])
    # Validate Create New Submissions modal
    dashboard_page.click_create_new_submission_button()
    # We recently became slow drawing this overlay (20151006)
    time.sleep(5)
    dashboard_page.validate_create_new_submission()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
