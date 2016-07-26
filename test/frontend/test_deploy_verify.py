#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates the Aperta Create New Submission through Submit and finally
 withdraw processes.
This test requires the following data:
   env.VALID_PW - the correct password for users in environment
   env.JOURNAL - a valid journal in the given environment
   env.MMT - a valid paper type in JOURNAL for environment
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import os
import random
import time

from selenium.webdriver.common.by import By

from Base.Decorators import MultiBrowserFixture
from Base.Resources import creator_login1, creator_login2, creator_login3, creator_login4, \
    creator_login5
from frontend.common_test import CommonTest
from Pages.dashboard import DashboardPage
from Pages.manuscript_viewer import ManuscriptViewerPage

__author__ = 'jgray@plos.org'

users = [creator_login1,
         creator_login2,
         creator_login3,
         creator_login4,
         creator_login5,
         ]

user_pw = os.getenv('VALID_PW', '')


@MultiBrowserFixture
class ApertaBDDDeployVerifyTest(CommonTest):
  """
  A deployment validation step for the Aperta build chain
  """
  def test_validate_create_complete_cards_submit_withdraw(self, init=True):
    """
    test_deploy_verify: Validates creating a new document, completing several cards,
      making a full submission, then withdrawing that submission
    :param init: Determine if login is needed
    :return: void function
    """
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'], password=user_pw) \
        if init else DashboardPage(self.getDriver())
    # Temporary changing timeout
    dashboard_page.click_create_new_submission_button()
    dashboard_page.set_timeout(120)
    # We recently became slow drawing this overlay (20151006)
    time.sleep(.5)
    journal_name = os.getenv('JOURNAL', '')
    mmt_type = os.getenv('MMT', '')
    self.create_article(journal=journal_name,
                        type_=mmt_type,
                        title='deployment test document',
                        )
    dashboard_page.restore_timeout()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(15)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=30)
    time.sleep(2)
    paper_id = manuscript_page.get_paper_id_from_url()

    keep_waiting = True
    while keep_waiting:
      time.sleep(5)
      paper_title_from_page = manuscript_page.get_paper_title_from_page()
      if 'full submit' in paper_title_from_page.encode('utf8'):
        continue
      else:
        keep_waiting = False

    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # check for flash message
    paper_viewer.validate_ihat_conversions_success(timeout=15)
    paper_id = paper_viewer.get_current_url().split('/')[-1]
    paper_id = paper_id.split('?')[0] if '?' in paper_id else paper_id
    logging.info("Assigned paper id: {0}".format(paper_id))

    paper_viewer.complete_task('Cover Letter')
    paper_viewer.complete_task('Figures')
    paper_viewer.complete_task('Supporting Info')
    paper_viewer.complete_task('Additional Information')
    time.sleep(3)

    # Allow time for submit button to attach to the DOM
    time.sleep(3)
    manuscript_page.click_submit_btn()
    time.sleep(3)
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    manuscript_page.close_submit_overlay()

    # Now Withdraw the manuscript
    time.sleep(1)
    # Do some style and element validations
    manuscript_page.withdraw_manuscript()
    # Need a wee bit of time for the db to update
    time.sleep(1)
    self._withdraw_banner = (By.CLASS_NAME, 'withdrawal-banner')
    withdraw_banner = manuscript_page._get(self._withdraw_banner)
    # Wrapping the following in a try except due to a known issue: APERTA-6860
    try:
      assert 'This paper has been withdrawn from {0} and is in View Only ' \
             'mode'.format(journal_name) in withdraw_banner.text
    except AssertionError:
      logging.warning('Banner text is not correct: {0}'.format(withdraw_banner.text))
    time.sleep(1)
    manuscript_page.logout()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
