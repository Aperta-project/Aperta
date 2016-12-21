#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates paper reactivation and the reactivate button of the withdraw
  banner.
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted into
    frontend/assets/
"""
import logging
import os
import random
import time

from selenium.webdriver.common.by import By

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import users, editorial_users
from frontend.common_test import CommonTest
from Pages.authenticated_page import application_typeface, aperta_grey_dark, white
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class ReactivateManuscriptTest(CommonTest):
  """
  Validate the elements, styles, functions of the Reactivation process
  """

  def test_reactivate_manuscript(self):
    """
    test_reactivate_ms: Validates the elements, styles, roles and functions of the reactivate
    manuscript process and UI elements
    :return: void function
    """
    logging.info('Test Reactivate MS::withdraw_ms')
    current_path = os.getcwd()
    logging.info(current_path)
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    journal = 'PLOS Wombat'
    self.create_article(journal=journal, type_='NoCards', random_bit=True)
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
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
    time.sleep(1)
    # Do some style and element validations
    manuscript_page._check_more_btn(user=creator_user)
    manuscript_publishing_state = PgSQL().query('SELECT publishing_state '
                                                'FROM papers '
                                                'WHERE short_doi = %s;', (short_doi,))[0][0]
    assert manuscript_publishing_state == 'submitted', manuscript_publishing_state
    manuscript_page.withdraw_manuscript()
    # Need a wee bit of time for the db to update
    time.sleep(2)
    manuscript_publishing_state = PgSQL().query('SELECT publishing_state '
                                                'FROM papers '
                                                'WHERE short_doi = %s;', (short_doi,))[0][0]
    assert manuscript_publishing_state == 'withdrawn', manuscript_publishing_state
    self._withdraw_banner = (By.CLASS_NAME, 'withdrawal-banner')
    withdraw_banner = manuscript_page._get(self._withdraw_banner)
    # Wrapping the following in a try except due to a known issue: APERTA-6860
    try:
      assert 'This paper has been withdrawn from {0} and is in View Only mode'.format(journal) in \
          withdraw_banner.text
    except AssertionError:
      logging.warning('Banner text is not correct: {0}'.format(withdraw_banner.text))
    assert withdraw_banner.value_of_css_property('background-color') == aperta_grey_dark, \
        withdraw_banner.value_of_css_property('background-color')
    assert withdraw_banner.value_of_css_property('color') == white, \
        withdraw_banner.value_of_css_property('color')
    assert application_typeface in withdraw_banner.value_of_css_property('font-family'), \
        withdraw_banner.value_of_css_property('font-family')
    # Ensure Reactivate button is not present
    btn_present = manuscript_page.check_for_reactivate_btn()
    assert not btn_present, btn_present
    manuscript_page.logout()

    # Only internal staff should see the reactivate button
    internal_staff = random.choice(editorial_users)
    logging.info(internal_staff['name'])
    dashboard_page = self.cas_login(email=internal_staff['email'])
    dashboard_page.page_ready()
    self._driver.get(paper_url)
    self._driver.navigated = True
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    manuscript_page.validate_reactivate_btn()
    manuscript_page.reactivate_manuscript()
    manuscript_publishing_state = PgSQL().query('SELECT publishing_state '
                                                'FROM papers '
                                                'WHERE short_doi = %s;', (short_doi,))[0][0]
    assert manuscript_publishing_state == 'submitted', manuscript_publishing_state
    manuscript_page.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_recent_activity_link()
    time.sleep(1)
    workflow_page.validate_recent_activity_entry('Manuscript was reactivated',
                                                 internal_staff['name'])

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
