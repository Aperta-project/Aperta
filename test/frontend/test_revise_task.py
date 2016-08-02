#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Revise Manuscript task
Automated test case for: fill response to reviweres and attach a file in Revise Manuscript task
"""
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import staff_admin_login, internal_editor_login, pub_svcs_login, \
    super_admin_login, prod_staff_login, creator_login1, creator_login2, \
    creator_login3, creator_login4, creator_login5, cover_editor_login, handling_editor_login
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'sbassi@plos.org'

staff_users = (staff_admin_login, internal_editor_login, prod_staff_login, pub_svcs_login,
               super_admin_login, handling_editor_login, cover_editor_login)
users = (creator_login1, creator_login2, creator_login3, creator_login4, creator_login5)


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
  def _test_response_to_reviewers(self):
    """
    NOTE: Disabled due to bug APERTA-6994
    test_revise_manuscript: Functional test of revise task. This test walks through the path to
    create an article, make a decision about the manuscript and the author will use the revise task
    card.
    """
    creator = random.choice(users)
    journal = 'PLOS Wombat'
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    # Create paper
    dashboard_page.click_create_new_submission_button()
    time.sleep(.5)
    paper_type = 'Research'
    logging.info('Creating Article in {0} of type {1}'.format(journal, paper_type))
    self.create_article(title='Testing Discussion Forum notifications',
                        journal=journal,
                        type_=paper_type,
                        random_bit=True,
                        )
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # check for flash message
    paper_viewer.validate_ihat_conversions_success(timeout=45)
    paper_id = paper_viewer.get_current_url().split('/')[-1]
    paper_id = paper_id.split('?')[0] if '?' in paper_id else paper_id
    logging.info("Assigned paper id: {0}".format(paper_id))
    paper_viewer.complete_task('Authors')
    paper_viewer.complete_task('Billing')
    paper_viewer.complete_task('Cover Letter')
    paper_viewer.complete_task('Figures')
    paper_viewer.complete_task('Supporting Info')
    paper_viewer.complete_task('Financial Disclosure')
    # Complete cards
    paper_viewer.click_submit_btn()
    paper_viewer.confirm_submit_btn()
    paper_viewer.close_submit_overlay()
    # logout
    paper_viewer.logout()
    # log as editor, invite a reviewer
    staff_user = random.choice(staff_users)
    logging.info('Logging in as user: {0}'.format(staff_user))
    dashboard_page = self.cas_login(email=staff_user['email'])
    if staff_user in (handling_editor_login, cover_editor_login):
      # Set up a handling editor, academic editor and cover editor for this paper
      self.set_editors_in_db(paper_id)
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    time.sleep(2)
    workflow_page.click_register_decision_card()
    workflow_page.complete_card('Register Decision')
    workflow_page.logout()
    # Login as user and complete Revise Manuscript
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    data = {'attach': 2}
    paper_viewer.complete_task('Revise Manuscript', data=data)
    return self

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
