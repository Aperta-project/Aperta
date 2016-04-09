#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.Resources import staff_admin_login, internal_editor_login, pub_svcs_login, \
    super_admin_login, prod_staff_login, creator_login1, creator_login2, \
    creator_login3, creator_login4, creator_login5, reviewer_login
from frontend.common_test import CommonTest
from Cards.invite_reviewer_card import InviteReviewersCard
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage
from selenium.webdriver.common.by import By

"""
This test case validates the Aperta Discussion Forum
Automated test case for: add discussion forum notification icons to MS
"""
__author__ = 'sbassi@plos.org'

staff_users = (staff_admin_login, internal_editor_login, prod_staff_login, pub_svcs_login,
               super_admin_login)

users = (creator_login1, creator_login2, creator_login3, creator_login4, creator_login5)

@MultiBrowserFixture
class ReviseManuscriptTest(CommonTest):
  """
  test_revise_manuscript: XXXX
  AC out of: APERTA-6419
     - When the user is added to a discussion topic
     - When mentioned in a topic
     - Numbered notifications

  """
  def test_response_to_reviewers(self):
    """
    XXXXXXXXXX
    """
    creator = random.choice(users)
    journal = 'PLOS Wombat'
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    # Create paper
    dashboard_page.set_timeout(120)
    dashboard_page.click_create_new_submission_button()
    time.sleep(.5)
    paper_type = 'Research'
    logging.info('Creating Article in {0} of type {1}'.format(journal, paper_type))
    self.create_article(title='Testing Discussion Forum notifications',
                        journal=journal,
                        type_=paper_type,
                        random_bit=True,
                        )
    dashboard_page.restore_timeout()
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # check for flash message
    paper_viewer.validate_ihat_conversions_success()
    paper_id = paper_viewer.get_current_url().split('/')[-1]
    paper_id = paper_id.split('?')[0] if '?' in paper_id else paper_id
    logging.info("Assigned paper id: {0}".format(paper_id))

    paper_viewer.complete_task('Billing')
    paper_viewer.complete_task('Cover Letter')
    paper_viewer.complete_task('Figures')
    paper_viewer.complete_task('Supporting Info')
    paper_viewer.complete_task('Authors')
    paper_viewer.complete_task('Financial Disclosure')
    # Complete cards
    paper_viewer.click_submit_btn()
    paper_viewer.confirm_submit_btn()
    paper_viewer.close_submit_overlay()
    # logout
    paper_viewer.logout()
    # log as editor, there is no need to invite a reviewer because the editor
    # can review and this path is already tested elsewhere.
    user_type = random.choice(staff_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    time.sleep(10)
    # NOTE: logout not done!!!
    # Invite a reviewer
    user_type = random.choice(staff_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the workflow page to load and for the elements to attach to DOM,
    #   otherwise failures
    time.sleep(10)
    workflow_page.click_card('invite_reviewers')
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.invite_reviewer(reviewer_login, 'TITLE XXX')
    paper_viewer.logout()
    # login as reviewer
    logging.info('Logging in as user: {0}'.format(reviewer_login))
    dashboard_page = self.cas_login(email=reviewer_login['email'])
    # accept invitation
    import pdb; pdb.set_trace()
    dashboard_page.accept_all_invitations()
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())







    paper_viewer.logout()
    user_type = random.choice(staff_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.post_new_discussion(topic='Testing discussion on paper {}'.format(paper_id),
                                     msg='', participants=[creator['user']])
    # send another msg
    paper_viewer.logout()
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())

    user_type = random.choice(staff_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # click on discussion icon
    paper_viewer.post_discussion('@' + creator['user'])
    paper_viewer.logout()
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # look for icon
    red_badge = paper_viewer._get(paper_viewer._badge_red)
    red_badge_last = int(red_badge.text)
    assert red_badge_first + 1 == red_badge_last, (red_badge_first, red_badge_last)
    red_badge.click()
    # close and check if any badge
    paper_viewer.close_sheet()
    paper_viewer.set_timeout(2)
    paper_viewer.restore_timeout()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
