#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates metadata versioning for Aperta.
"""
__author__ = 'sbassi@plos.org'

import time
import random
import pdb

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
  def _test_metadata_versioning(self):
    """
    Test metadata versioning (APERTA-3368).
    AC:
     - Version information
     - add/edit/delete functionality disabled
    Since this task is not completed, this test is disabled until the functionality is in place.
    """
    title = 'For metadata versioning'
    #if True: # for debugging
    if self.check_article(title):
      init = True if 'users/sign_in' in self._driver.current_url else False
      article = self.select_preexisting_article(title=title, init=init)
    else:
      # Create new article
      title = self.create_article(title=title,
                                 journal='PLOS Lemur',
                                 type_='Research',
                                 random_bit=True,
                                 init=False)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.complete_card('Billing')
    paper_viewer.complete_card('Authors')
    paper_viewer.complete_card('Cover Letter')
    paper_viewer.complete_card('Figures')
    paper_viewer.complete_card('Supporting Info')
    paper_viewer.complete_card('Upload Manuscript')
    # Click submit
    paper_viewer.press_submit_btn()
    paper_viewer.confirm_submit_btn()
    paper_viewer.close_submit_overlay()
    # go to workflow
    paper_viewer.click_workflow_lnk()
    workflow_page = WorkflowPage(self.getDriver())
    # press register decision
    workflow_page._get(workflow_page._register_decision_button).click()
    # register decision (major)
    register_decision_card = RegisterDecisionCard(self.getDriver())
    register_decision_card.register_decision('Major Revision')
    time.sleep(1)
    # manuscript
    workflow_page._get(workflow_page._manuscript_link).click()
    time.sleep(1)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    time.sleep(1)
    # TODO: file a bug about the need for refresh this
    paper_viewer.refresh()
    alert = self._driver.switch_to_alert()
    try:
      alert.accept()
    except NoAlertPresentException:
      # Sometimes there is no alert on this operationm in thise case, do nothing
      pass
    time.sleep(1)
    # TODO: Upload image
    paper_viewer.complete_card('Revise Manuscript')
    time.sleep(1)
    # TODO: Submit again
    return self

  def test_metadata_versioning(self):
    """
    Test metadata versioning (APERTA-5747).
    AC:
    """
    title = 'For metadata versioning'
    types = ('Research', 'Research w/Initial Decision Card')
    types = ('Research w/Initial Decision Card',)
    journal_type = random.choice(types)

    new_prq = {'q1':'Yes', 'q2':'Yes', 'q3': [0,1,0,0], 'q4':'New Data',
                      'q5':'More Data'}
    #if True: # for debugging
    if self.check_article(title, user='jgray_author'):
      init = True if 'users/sign_in' in self._driver.current_url else False
      article = self.select_preexisting_article(title=title, init=init)
    else:
      # Create new article
      title = self.create_article(title=title,
                                 journal='PLOS Wombat',
                                 type_=journal_type,
                                 random_bit=True,
                                 init=False,
                                 user='jgray_author')
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_id = paper_viewer.get_current_url().split('/')[-1]
    print("Assigned paper id: {}".format(paper_id))
    # Test
    #paper_viewer.logout()

    #paper_viewer.complete_card('Billing')

    #paper_viewer.click_task('Billing')
    paper_viewer.complete_task('Billing')
    #paper_viewer.click_task('Billing')
    time.sleep(.1)
    paper_viewer.complete_task('Cover Letter')
    paper_viewer.complete_task('Figures')
    paper_viewer.complete_task('Supporting Info')
    paper_viewer.complete_task('Authors')
    paper_viewer.complete_task('Publishing Related Questions')
    if journal_type == 'Research':
      pass
      #paper_viewer.complete_task('Publishing Related Questions')
    time.sleep(3)
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
    dashboard_page.view_invitations()
    # the Editor should accept the assignation as editor
    dashboard_page.accept_invitations()
    # go to article
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    if journal_type == 'Research w/Initial Decision Card':
      # click register initial decision on task
      #pdb.set_trace()
      paper_viewer.complete_task('Initial Decision')
      time.sleep(1)
      paper_viewer.logout()
      # Log in as a author to make first final submission
      dashboard_page = self.login(email=au_login['user'], password=login_valid_pw)
      dashboard_page.go_to_manuscript(paper_id)
      paper_viewer = ManuscriptViewerPage(self.getDriver())
      time.sleep(2)
      # submit article
      ##pdb.set_trace()
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
      # register decision as accept with revisions
      #data = ('Major Revision', 'Your manuscript needs major revision')
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
      print([x.text for x in bar_items])
      pdb.set_trace()


      #pdb.set_trace()



    else:
      pass
    paper_viewer.logout()
    # Log in as a user to make modifications
    dashboard_page = self.login(email=sa_login['user'], password=login_valid_pw)
    # go to article
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # do some changes

    #pdb.set_trace()

    #button


    # go to article
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # go to workflow
    paper_viewer.click_workflow_lnk()
    workflow_page = WorkflowPage(self.getDriver())
    # press register decision
    workflow_page._get(workflow_page._register_decision_button).click()
    # register decision (major)
    register_decision_card = RegisterDecisionCard(self.getDriver())
    register_decision_card.register_decision('Major Revision')
    time.sleep(1)

    paper_viewer.logout()

    # log as editor jgray_editor
    dashboard_page = self.login(email=he_login['user'], password=login_valid_pw)
    # go to article
    dashboard_page.go_to_manuscript(paper_id)

    XXXX

    # manuscript
    workflow_page._get(workflow_page._manuscript_link).click()
    time.sleep(1)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    time.sleep(1)
    # TODO: file a bug about the need for refresh this
    paper_viewer.refresh()
    alert = self._driver.switch_to_alert()
    try:
      alert.accept()
    except NoAlertPresentException:
      # Sometimes there is no alert on this operationm in thise case, do nothing
      pass
    time.sleep(1)
    XXXXXX
    # TODO: Upload image
    paper_viewer.complete_card('Revise Manuscript')
    time.sleep(1)
    # TODO: Submit again
    return self




if __name__ == '__main__':
  CommonTest._run_tests_randomly()
