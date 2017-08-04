#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Revise Manuscript task
Automated test case for: fill response to reviweres and attach a file in Revise Manuscript task
"""
import logging
import os
import random
import time

from loremipsum import generate_paragraph

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users, admin_users
from frontend.common_test import CommonTest
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Tasks.upload_manuscript_task import UploadManuscriptTask
from .Pages.workflow_page import WorkflowPage
from frontend.Tasks.basetask import BaseTask

__author__ = 'sbassi@plos.org'

staff_users = editorial_users + admin_users


@MultiBrowserFixture
class ReviseManuscriptTest(CommonTest):
  """
  Test related with the following Use Case: We need to provide a
  more obvious place for the author to give us their response to reviewers. Different ways
  to response to reviewers are tested.
  AC out of: APERTA-6419
     - Upload files to Response to Reviewers (NOTE: Testing only one file due to APERTA-6672)
     - Fill a response in a text area in Response to Reviewers
  """
  def test_response_to_reviewers(self):
    """
    NOTE: Disabled due to bug APERTA-6994
    test_revise_manuscript: Functional test of revise task. This test walks through the path to
    create an article, make a decision about the manuscript and the author will use the revise task
    card.
    """
    logging.info('Test Revise task::response_to_reviewers')
    current_path = os.getcwd()
    logging.info(current_path)
    creator = random.choice(users)
    journal = 'PLOS Wombat'
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    # Create paper
    dashboard_page.click_create_new_submission_button()
    time.sleep(.5)
    paper_type = 'NoCards'
    logging.info('Creating Article in {0} of type {1}'.format(journal, paper_type))
    self.create_article(title='Testing Discussion Forum notifications', journal=journal,
                        type_=paper_type, random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    logging.info("Assigned paper short doi: {0}".format(short_doi))
    # Complete cards

    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.complete_task('Title And Abstract')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_submit_overlay()

    # logout
    manuscript_page.logout()
    # log as editor, invite a reviewer
    staff_user = random.choice(staff_users)
    logging.info('Logging in as user: {0}'.format(staff_user))
    dashboard_page = self.cas_login(email=staff_user['email'])
    # go to article id short_doi
    dashboard_page.go_to_manuscript(short_doi)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # go to wf
    manuscript_page.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    time.sleep(2)
    workflow_page.click_register_decision_card()
    workflow_page.complete_card('Register Decision')
    workflow_page.logout()

    # Login as user and complete Revise Manuscript
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.go_to_manuscript(short_doi)
    manuscript_page = ManuscriptViewerPage(self.getDriver())

    manuscript_page.page_ready()
    data = {'attach': 2}
    manuscript_page.complete_task('Response to Reviewers', data=data)
    # This needs to be completed after any decision
    manuscript_page.complete_task('Title And Abstract')

    # replace first version
    manuscript_page.click_task('Upload Manuscript')
    upms = UploadManuscriptTask(self.getDriver())
    upms.task_ready()
    upms.replace_manuscript()

    while not upms.completed_state():
      upms.click_completion_button()
      time.sleep(1)

    manuscript_page.click_task('Upload Manuscript')
    manuscript_page.page_ready()
    # This needs to be completed a second time now
    manuscript_page.complete_task('Title And Abstract')

    # submit and logout
    time.sleep(1)
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_submit_overlay()
    manuscript_page.logout()

    # log back in as staff_user
    logging.info('Logging in again as user: {0}'.format(staff_user))
    dashboard_page = self.cas_login(email=staff_user['email'])
    dashboard_page.page_ready()
    # go to article id short_doi
    dashboard_page.go_to_manuscript(short_doi)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()

    # go to wf
    manuscript_page.click_workflow_link()

    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_register_decision_card()
    workflow_page.complete_card('Register Decision')
    workflow_page.click_register_decision_card()
    time.sleep(3)
    decision_history = workflow_page.get_decision_history_summary()
    assert decision_history[0].text.replace('\n', ' ') == '1.0 Major Revision', decision_history[0].text
    assert decision_history[1].text.replace('\n', ' ') == '0.0 Major Revision', decision_history[1].text
    workflow_page.logout()

    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # need to complete this task again after providing new manuscript
    paper_viewer.complete_task('Response to Reviewers', data={'text': generate_paragraph()[2],
                                                              'response_number': 2})

    data = {'attach': 2}
    manuscript_page.complete_task('Response to Reviewers', data=data)

    return self

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
