#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates Paper submission and initial Decision.
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into frontend/assets/docs/
"""
__author__ = 'sbassi@plos.org'

import os
import random
import time
from decimal import Decimal

from selenium.webdriver.common.by import By
from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_pw, au_login, he_login
from frontend.common_test import CommonTest
from Cards.initial_decision_card import InitialDecisionCard
from Cards.figures_card import FiguresCard
from Pages.dashboard import DashboardPage
from Pages.login_page import LoginPage
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

docx = ['2014_04_27 Bakowski et al main text_subm.docx',
        '120220_PLoS_Genetics_review.docx',
        'CRX.pone.0103411.docx',
        'GIANT-gender-main_20130310.docx',
        'NF-kB-Paper_manuscript.docx',
        'NorenzayanetalPLOS.docx',
        'pgen.1004127.docx',
        'PGENETICS-D-13-02065R1_FTC.docx',
        'PLosOne_Main_Body_Ravi_Bansal_Brad_REVISED.docx',
        'PONE-D-12-25504.docx',
        'PONE-D-12-27950.docx',
        'PONE-D-13-02344.docx',
        'PONE-D-13-14162.docx',
        'PONE-D-13-19782.docx',
        'PONE-D-13-38666.docx',
        'PONE-D-14-12686.docx',
        'PONE-D-14-17217.docx',
        'pone.0100365.docx',
        'pone.0100948.docx',
        'ppat.1004210.docx',
        'PPATHOGENS-D-14-01213.docx',
        'RTN.pone.0072333.docx',
        'Schallmo_PLOS_RevisedManuscript.docx',
        'Spindler_2014_rerevised.docx',
        'Thammasri_PONE_D13_12078_wo.docx',
        ]

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
    login_page.enter_login_field(au_login)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()

    dashboard_page = DashboardPage(self.getDriver())
    # Validate Create New Submissions modal
    dashboard_page.click_create_new_submission_button()
    # We recently became slow drawing this overlay (20151006)
    time.sleep(.5)
    title = dashboard_page.title_generator()
    dashboard_page.enter_title_field(title)
    dashboard_page.select_journal_and_type('PLOS Wombat', 'Images+InitialDecision')
    doc2upload = random.choice(docx)
    fn = os.path.join(os.getcwd(), 'frontend/assets/docs/', doc2upload)
    if os.path.isfile(fn):
      self._driver.find_element_by_id('upload-files').send_keys(fn)
    else:
      raise IOError('Docx file not found: {}'.format(fn))
    dashboard_page.click_upload_button()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success()
    paper_url = manuscript_page.get_current_url()
    print('The paper ID of this newly created paper is: ' + paper_url)
    paper_id = paper_url.split('papers/')[1]
    # Get paper version for AC 6
    version_before = Decimal(manuscript_page.get_manuscript_version()[1:])
    # figures
    manuscript_page.complete_card('Figures')
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
    login_page.enter_login_field(he_login)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    dashboard_page = DashboardPage(self.getDriver())
    # look for the article in paper tracker
    # go to paper tracker
    dashboard_page._get(dashboard_page._dashboard_top_menu_paper_tracker).click()
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
    assert "An initial decision of 'invite full submission' decision has been made." in \
      alert_msg.text, alert_msg.text
    # Test that card is editable by author
    manuscript_page.logout()
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(au_login)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    time.sleep(2)
    self._driver.get(paper_url)
    self._driver.navigated = True
    # open Image card
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    time.sleep(1)
    manuscript_page.click_card('Figures')
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
