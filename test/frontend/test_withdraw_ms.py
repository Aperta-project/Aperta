#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates paper withdrawal and the withdraw banner
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted into
    frontend/assets/
"""
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import users, editorial_users
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class WithdrawManuscriptTest(CommonTest):
  """
  Validate the elements, styles, functions of the Withdraw process
  """

  def test_withdraw_manuscript(self):
    """
    test_withdraw_ms: Validates the elements, styles, roles and functions of the withdraw
    manuscript process and UI elements
    :return: void function
    """
    logging.info('Test Withdraw MS')
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    journal = 'PLOS Wombat'
    self.create_article(journal=journal, type_='NoCards', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_url = manuscript_page.get_current_url()
    short_doi = manuscript_page.get_short_doi()
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.close_modal()
    manuscript_page._wait_for_not_element(manuscript_page._overlay_header_close, 0.05)
    # Do some style and element validations
    manuscript_page._check_more_btn(user=creator_user)

    manuscript_publishing_state = PgSQL().query('SELECT publishing_state '
                                                'FROM papers '
                                                'WHERE short_doi = %s;', (short_doi,))[0][0]
    assert manuscript_publishing_state == 'submitted', manuscript_publishing_state
    manuscript_page.withdraw_manuscript()
    # Need a wee bit of time for the db to update
    time.sleep(1)
    manuscript_publishing_state = PgSQL().query('SELECT publishing_state '
                                                'FROM papers '
                                                'WHERE short_doi = %s;', (short_doi,))[0][0]
    assert manuscript_publishing_state == 'withdrawn', manuscript_publishing_state
    manuscript_page.validate_withdraw_banner(journal)
    manuscript_page.logout()

    # Login as a privileged user to check the Recent Activity entry
    internal_staff = random.choice(editorial_users)
    logging.info(internal_staff['name'])
    dashboard_page = self.cas_login(email=internal_staff['email'])
    dashboard_page.page_ready()
    self._driver.get(paper_url)
    self._driver.navigated = True
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    manuscript_page.validate_reactivate_btn()

    manuscript_page.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.validate_withdraw_banner(journal)
    workflow_page.click_recent_activity_link()
    workflow_page.validate_recent_activity_entry('Manuscript was withdrawn',
                                                 creator_user['name'])

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
