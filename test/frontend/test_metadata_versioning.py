#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates metadata versioning for Aperta.
"""
__author__ = 'sbassi@plos.org'

import time
import random

from selenium.common.exceptions import NoAlertPresentException

from Base.Decorators import MultiBrowserFixture
from Cards.basecard import BaseCard
from Cards.register_decision_card import RegisterDecisionCard
from Cards.invite_editor_card import InviteEditorCard
from frontend.common_test import CommonTest
from Pages.dashboard import DashboardPage
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage
from Base.Resources import login_valid_pw, au_login, he_login, sa_login

@MultiBrowserFixture
class MetadataVersioningTest(CommonTest):
  """
  Since metadata versioning is not developed yet, this calls create condition
  for testing by creating an article, filling all required cards, submitting.

  APERTA-5747
  """

  def test_metadata_versioning(self):
    """
    Test metadata versioning (APERTA-5747).
    AC being tested:

    - can see diff comparing submitted versions of metadata, including minor versions
    - Diff Icon in closed card
    - Version Stamp in cards
    - Changed text
    - Added text

    Note: Due to bugs APERTA-5794, APERTA-5810, APERTA-5808 and PERTA-5849, assertions
    are not implemented in this method
    """
    title = 'For metadata versioning'
    types = ('Research', 'Research w/Initial Decision Card')
    journal_type = random.choice(types)
    new_prq = {'q1':'Yes', 'q2':'Yes', 'q3': [0,1,0,0], 'q4':'New Data',
               'q5':'More Data'}
    dashboard_page = self.login(email=au_login['user'], password=login_valid_pw)
    title = self.create_article(title=title,
                                journal='PLOS Wombat',
                                type_=journal_type,
                                random_bit=True,
                                init=False,
                                user='jgray_author')
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_id = paper_viewer.get_current_url().split('/')[-1]
    paper_id = paper_id.split('?')[0] if '?' in paper_id else paper_id
    print("Assigned paper id: {}".format(paper_id))
    paper_viewer.complete_task('Billing')
    time.sleep(.1)
    paper_viewer.complete_task('Cover Letter')
    paper_viewer.complete_task('Figures')
    paper_viewer.complete_task('Supporting Info')
    paper_viewer.complete_task('Authors')
    paper_viewer.complete_task('Additional Information')
    time.sleep(3)
    # get title
    # check after manuscript is uploaded
    title = paper_viewer.get_title()
    # make initial submission
    paper_viewer.click_submit_btn()
    paper_viewer.confirm_submit_btn()
    paper_viewer.close_submit_overlay()
    # logout
    paper_viewer.logout()
    # log as an Admin to ad jgray as editor to this paper
    dashboard_page = self.login(email=sa_login['user'], password=login_valid_pw)
    # go to article
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.click_workflow_lnk()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.click_add_new_card()
    workflow_page.add_invite_editor_card()
    workflow_page.click_invite_editor_card()
    invite_editor_card = InviteEditorCard(self.getDriver())
    invite_editor_card.invite_editor(he_login)
    paper_viewer.logout()
    # log as editor jgray_editor to accept invitation and accept initial submission
    dashboard_page = self.login(email=he_login['user'], password=login_valid_pw)
    dashboard_page.click_view_invitations()
    # the Editor should accept the assignation as editor
    dashboard_page.accept_invitation(title)
    # go to article
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    if journal_type == 'Research w/Initial Decision Card':
      # click register initial decision on task
      paper_viewer.complete_task('Initial Decision')
      time.sleep(1)
      paper_viewer.logout()
      # Log in as a author to make first final submission
      dashboard_page = self.login(email=au_login['user'], password=login_valid_pw)
      dashboard_page.go_to_manuscript(paper_id)
      paper_viewer = ManuscriptViewerPage(self.getDriver())
      time.sleep(2)
      # submit article
      paper_viewer.click_submit_btn()
      paper_viewer.confirm_submit_btn()
      paper_viewer.close_submit_overlay()
      # logout
      paper_viewer.logout()
      # Log as editor to approve the manuscript with modifications
      dashboard_page = self.login(email=he_login['user'], password=login_valid_pw)
      # go to article
      dashboard_page.go_to_manuscript(paper_id)
      paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.complete_task('Register Decision')
    time.sleep(1)
    paper_viewer.logout()
    # Log in as a author to make some changes
    dashboard_page = self.login(email=au_login['user'], password=login_valid_pw)
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.complete_task('Publishing Related Questions', click_override=True, data=new_prq, click=True)
    # check versioning
    version_btn = paper_viewer._get(paper_viewer._tb_versions_link)
    version_btn.click()
    bar_items = paper_viewer._gets(paper_viewer._bar_items)
    # click on
    bar_items[2].find_elements_by_tag_name('option')[2].click()
    # Following command disabled due to bug APERTA-5849
    #paper_viewer.click_task('prq')
    return self


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
