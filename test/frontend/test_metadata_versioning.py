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
    # Test
    #paper_viewer.logout()

    #paper_viewer.complete_card('Billing')

    paper_viewer.click_task('Billing')
    paper_viewer.complete_task('Billing')

    paper_viewer.click_task('Authors')
    paper_viewer.complete_task('Authors')
    paper_viewer.click_task('Cover Letter')
    paper_viewer.complete_task('Cover Letter')
    paper_viewer.click_task('Figures')
    paper_viewer.complete_task('Figures')
    paper_viewer.click_task('Supporting Info')
    paper_viewer.complete_task('Supporting Info')
    #paper_viewer.complete_card('Upload Manuscript')
    if journal_type == 'Research':
      paper_viewer.click_task('Publishing Related Questions')
      paper_viewer.complete_task('Publishing Related Questions')
    time.sleep(1)
    # Click submit
    paper_viewer.click_submit_btn()
    paper_viewer.confirm_submit_btn()
    paper_viewer.close_submit_overlay()
    # logout

    paper_viewer.logout()

    # log as an Admin to ad jgray as editor to this paper

    # log as an Admin to ad jgray as editor to this paper
    dashboard_page = self.login(email=sa_login['user'], password=login_valid_pw)
    # go to article
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.click_workflow_lnk()
    workflow_page = WorkflowPage(self.getDriver())
    #pdb.set_trace()
    workflow_page.click_add_new_card()
    workflow_page.add_invite_editor_card()
    workflow_page.click_invite_editor_card()
    invite_editor_card = InviteEditorCard(self.getDriver())
    invite_editor_card.invite_editor(he_login)
    # END TEST
    paper_viewer.logout()

    # log as editor jgray_editor
    dashboard_page = self.login(email=he_login['user'], password=login_valid_pw)
    dashboard_page.view_invitations()
    dashboard_page.accept_invitations()
    # the Editor should accept the assignation as editor

    # go to article
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    if journal_type == 'Research w/Initial Decision Card':
      # click register initial decision
      paper_viewer.click_workflow_lnk()
      workflow_page = WorkflowPage(self.getDriver())
      # press register decision
      workflow_page._get(workflow_page._register_decision_button).click()
      # register decision (major)
      register_decision_card = RegisterDecisionCard(self.getDriver())
      register_decision_card.register_initial_decision('Invite')
      time.sleep(1)
    else:
      pass
    paper_viewer.logout()
    # Log in as a user to make modifications
    dashboard_page = self.login(email=sa_login['user'], password=login_valid_pw)
    # go to article
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    pdb.set_trace()

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
