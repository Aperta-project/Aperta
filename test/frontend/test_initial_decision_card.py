#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates Paper submission and initial Decision.
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into frontend/assets/docs/
"""
__author__ = 'sbassi@plos.org'

from decimal import Decimal
import logging
import os
import random
import time

from selenium.webdriver.common.by import By
from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_pw, au_login, sa_login, docs
from frontend.common_test import CommonTest
from Cards.initial_decision_card import InitialDecisionCard
from Cards.figures_card import FiguresCard
from Pages.dashboard import DashboardPage
from Pages.login_page import LoginPage
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage


@MultiBrowserFixture
class InitialDecisionCardTest(CommonTest):
  """
  AC from APERTA-5400

  1. Editor can indicate their decision
  2. Text box for reject or invitation letter is blank.
  3. Editor can customize the text that will be sent to authors.
  4. Email should be sent to creating author/corresponding author
  5. Sending an invitation for full submission (unless the visual editor is gone) will make the MS and cards editable to the authors.
  6. The minor version of this article should change in a manner consistent with APERTA-3407 and with previous versioning logic.

  TODO: AC#4 to be done whern APERTA-5671 is completed.

  """

  def test_initial_submit_actions(self):
    """
    Validates AC 1, 2, 3, 5 and 6 from APERTA-5400
    """
    # Users logs in and make a submition
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(au_login['user'])
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    # Time needed for log in
    #time.sleep(5)
    dashboard_page = DashboardPage(self.getDriver())
    dashboard_page.set_timeout(60)
    self.create_article(journal = 'PLOS Wombat',
                        type_ = 'Images+InitialDecision',
                        random_bit = True,
                        init = False,
                        )
    dashboard_page.restore_timeout()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success()
    # Note: Request title to make sure the required page is loaded
    paper_url = manuscript_page.get_current_url()
    logging.info('The paper ID of this newly created paper is: {}'.format(paper_url))
    paper_id = paper_url.split('papers/')[1]

    # Get paper version for AC 6
    version_before = Decimal(manuscript_page.get_manuscript_version()[1:])
    # figures
    manuscript_page.click_task('Figures')
    manuscript_page.complete_task('Figures')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    #manuscript_page.close_submit_overlay()
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()
    # login as editor
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(sa_login['user'])
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    dashboard_page = DashboardPage(self.getDriver())
    # look for the article in paper tracker
    # go to paper tracker
    dashboard_page._get(dashboard_page._nav_paper_tracker_link).click()
    # Go to workflow
    url = self._driver.current_url
    paper_url = '{}//{}/papers/{}'.format(url.split('/')[0], url.split('/')[2], paper_id)
    paper_workflow_url = '{}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    # go to card
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.click_card('initial_decision')
    # time.sleep(3)
    initial_decision = InitialDecisionCard(self.getDriver())
    # AC 2
    assert initial_decision._get(initial_decision._decision_letter_textarea).text == ''
    # AC 1 and 3
    initial_decision.execute_decision('invite')
    # look for alert info
    alert_msg = initial_decision._get(initial_decision._alert_info)
    assert "An initial decision of 'Invite full submission' decision has been made." in \
      alert_msg.text, alert_msg.text
    # Test that card is editable by author
    manuscript_page.logout()
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(au_login['user'])
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    time.sleep(2)
    self._driver.get(paper_url)
    self._driver.navigated = True
    # open Image card
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    time.sleep(1)
    manuscript_page.click_task('Figures')
    # test if editable
    figures_card = FiguresCard(self.getDriver())
    # AC 5
    if not figures_card.is_question_checked():
      figures_card.check_question()
      assert figures_card.is_question_checked() == True
    else:
      figures_card.check_question()
      assert figures_card.is_question_checked() == False
    # AC 6
    version_after = Decimal(manuscript_page.get_manuscript_version()[1:])
    assert version_after - version_before == Decimal('0.1'), (version_after, version_before)


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
