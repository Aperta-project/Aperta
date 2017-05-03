#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates Paper submission and invite reviewer
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import prod_staff_login, reviewer_login, users, editorial_users, test_journal
from frontend.common_test import CommonTest
from Cards.invite_reviewer_card import InviteReviewersCard
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class InviteReviewersCardTest(CommonTest):
  """
  Validate the elements, styles, functions of the Invite Reviewers card
  """

  def test_smoke_invite_reviewers_styles_elements(self):
    logging.info('Test Invite Reviewers::elements and styles')
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    mmt = 'OnlyInitialDecisionCard'
    self.create_article(journal='PLOS Wombat', type_=mmt, random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.close_infobox()
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    paper_id = manuscript_page.get_paper_id_from_short_doi(short_doi)
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()
    # login as editorial user
    editorial_user = random.choice(editorial_users)
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('invite_reviewers')
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.card_ready()
    invite_reviewers.validate_card_elements_styles(reviewer_login, 'reviewer', short_doi)
    manuscript_title = PgSQL().query('SELECT title '
                                     'FROM papers WHERE short_doi = %s;', (short_doi,))[0][0]
    manuscript_title = unicode(manuscript_title,
                               encoding='utf-8',
                               errors='strict')
    # The title we pass in here must be a unicode object if there is utf-8 data present
    invite_reviewers.validate_invite(reviewer_login,
                                     mmt,
                                     manuscript_title,
                                     creator_user,
                                     short_doi)
    invite_reviewers.click_close_button()
    workflow_page.logout()

    # login as reviewer respond to invite
    dashboard_page = self.cas_login(email=reviewer_login['email'])
    dashboard_page.page_ready()
    dashboard_page.click_view_invites_button()
    dashboard_page.accept_invitation(manuscript_title)
    dashboard_page.logout()

    # log back in as editorial user and validate status display on card
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    workflow_page.click_card('invite_reviewers')
    time.sleep(3)
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.card_ready()
    invite_reviewers.validate_card_header(short_doi)
    invite_reviewers.validate_card_elements_styles(creator_user, 'reviewer', short_doi)

  def test_core_invite_reviewers_actions(self):
    """
    test_invite_reviewers_card: Validates the elements, styles, roles and functions of invite
      reviewers from new document creation through inviting reviewer, validation of the invite on
      the invitees dashboard, acceptance and rejections
    :return: void function
    """
    logging.info('Test Invite Reviewers::actions')
    current_path = os.getcwd()
    logging.info(current_path)
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    mmt = 'OnlyInitialDecisionCard'
    self.create_article(journal='PLOS Wombat', type_=mmt, random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.close_infobox()
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    paper_id = manuscript_page.get_paper_id_from_short_doi(short_doi)
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()
    # login as editorial user
    editorial_user = random.choice(editorial_users)
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('invite_reviewers')
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.card_ready()
    manuscript_title = PgSQL().query('SELECT title '
                                     'FROM papers WHERE short_doi = %s;', (short_doi,))[0][0]
    manuscript_title = unicode(manuscript_title,
                               encoding='utf-8',
                               errors='strict')
    # The title we pass in here must be a unicode object if there is utf-8 data present
    invite_reviewers.validate_invite(reviewer_login,
                                     mmt,
                                     manuscript_title,
                                     creator_user,
                                     short_doi)
    # Invite a second user to invite then delete before acceptance
    invite_reviewers.validate_invite(prod_staff_login,
                                     mmt,
                                     manuscript_title,
                                     creator_user,
                                     short_doi)
    logging.info('Revoking invite for {0}'.format(prod_staff_login['name']))
    invite_reviewers.revoke_invitee(prod_staff_login, 'Reviewer')
    invite_reviewers.click_close_button()
    workflow_page.logout()

    # login as reviewer respond to invite
    dashboard_page = self.cas_login(email=reviewer_login['email'])
    dashboard_page.page_ready()
    dashboard_page.click_view_invites_button()
    dashboard_page.validate_invitation_in_overlay(mmt=mmt,
                                                  invitation_type='Reviewers',
                                                  paper_id=paper_id)
    invite_response, response_data = dashboard_page.accept_or_reject_invitation(manuscript_title)
    logging.info('Invitees response to review request was {0}'.format(invite_response))
    # If accepted, validate new assignment in db
    wombat_journal_id = PgSQL().query('SELECT id '
                                      'FROM journals '
                                      'WHERE name = \'PLOS Wombat\';')[0][0]
    reviewer_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'areviewer\';')[0][0]
    reviewer_role_for_env = PgSQL().query('SELECT id '
                                          'FROM roles '
                                          'WHERE journal_id = %s '
                                          'AND name = \'Reviewer\';', (wombat_journal_id,))[0][0]
    try:
      test_for_role = PgSQL().query('SELECT role_id FROM assignments WHERE user_id = %s '
                                    'AND assigned_to_type=\'Paper\' and assigned_to_id = %s;',
                                    (reviewer_user_id, paper_id))[0][0]
    except IndexError:
      test_for_role = False
    if invite_response == 'Accept':
      assert test_for_role == reviewer_role_for_env, 'assigned role, {0}, is not the expected ' \
                                                     'value: {1}'.format(test_for_role,
                                                                         reviewer_role_for_env)
    elif invite_response == 'Reject':
      assert not test_for_role
      # search for reply
      reasons, suggestions = PgSQL().query('SELECT decline_reason, reviewer_suggestions '
                                           'FROM invitations '
                                           'WHERE invitee_id = %s '
                                           'AND state=\'declined\' '
                                           'AND invitee_role=\'Reviewer\' '
                                           'AND decline_reason LIKE %s '
                                           'AND reviewer_suggestions LIKE %s;',
                                           (reviewer_user_id,
                                            response_data[0]+'%',
                                            response_data[1]+'%'))[0]
      assert response_data[0] in reasons
      assert response_data[1] in suggestions
    dashboard_page.logout()

    # log back in as editorial user and validate status display on card
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    workflow_page.click_card('invite_reviewers')
    time.sleep(3)
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.card_ready()
    invite_reviewers.validate_response(reviewer_login, invite_response,response_data[0],
                                       response_data[1])

  def test_core_invite_rescind_reinvite(self):
    """
    test_invite_reviewers_card: Validates the elements, styles, roles and functions of invite
      reviewers from new document creation through inviting reviewer, validation of the invite on
      the invitees dashboard, acceptance and rejections
    :return: void function
    """
    logging.info('Test Invite Reviewers::Invite Rescind Reinvite')
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    mmt = 'OnlyInitialDecisionCard'
    self.create_article(journal='PLOS Wombat', type_=mmt, random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.close_infobox()
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    paper_id = manuscript_page.get_paper_id_from_short_doi(short_doi)
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_modal()

    # logout and enter as editor
    manuscript_page.logout()
    # login as editorial user
    editorial_user = random.choice(editorial_users)
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('invite_reviewers')
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.card_ready()
    manuscript_title = PgSQL().query('SELECT title '
                                     'FROM papers WHERE short_doi = %s;', (short_doi,))[0][0]
    manuscript_title = unicode(manuscript_title,
                               encoding='utf-8',
                               errors='strict')
    invite_reviewers.validate_invite(reviewer_login,
                                     mmt,
                                     manuscript_title,
                                     creator_user,
                                     short_doi)
    logging.info('Revoking invite for {0}'.format(reviewer_login['name']))
    invite_reviewers.revoke_invitee(reviewer_login, 'Reviewer')
    invite_reviewers.validate_invite(reviewer_login,
                                     mmt,
                                     manuscript_title,
                                     creator_user,
                                     short_doi)
    invite_reviewers.click_close_button()
    workflow_page.logout()

    # login as reviewer respond to invite
    dashboard_page = self.cas_login(email=reviewer_login['email'])
    dashboard_page.page_ready()
    dashboard_page.click_view_invites_button()
    dashboard_page.validate_invitation_in_overlay(mmt=mmt,
                                                  invitation_type='Reviewers',
                                                  paper_id=paper_id)
    invite_response, response_data = dashboard_page.accept_or_reject_invitation(manuscript_title)
    logging.info('Invitees response to review request was {0}'.format(invite_response))
    # If accepted, validate new assignment in db
    wombat_journal_id = PgSQL().query('SELECT id '
                                      'FROM journals '
                                      'WHERE name = \'PLOS Wombat\';')[0][0]
    reviewer_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'areviewer\';')[0][0]
    reviewer_role_for_env = PgSQL().query('SELECT id '
                                          'FROM roles '
                                          'WHERE journal_id = %s '
                                          'AND name = \'Reviewer\';', (wombat_journal_id,))[0][0]
    try:
      test_for_role = PgSQL().query('SELECT role_id FROM assignments WHERE user_id = %s '
                                    'AND assigned_to_type=\'Paper\' and assigned_to_id = %s;',
                                    (reviewer_user_id, paper_id))[0][0]
    except IndexError:
      test_for_role = False
    if invite_response == 'Accept':
      assert test_for_role == reviewer_role_for_env, 'assigned role, {0}, is not the expected ' \
                                                     'value: {1}'.format(test_for_role,
                                                                         reviewer_role_for_env)
    elif invite_response == 'Reject':
      assert not test_for_role
      # search for reply
      reasons, suggestions = PgSQL().query('SELECT decline_reason, reviewer_suggestions '
                                           'FROM invitations '
                                           'WHERE invitee_id = %s '
                                           'AND state=\'declined\' '
                                           'AND invitee_role=\'Reviewer\' '
                                           'AND decline_reason LIKE %s '
                                           'AND reviewer_suggestions LIKE %s;',
                                           (reviewer_user_id,
                                            response_data[0]+'%',
                                            response_data[1]+'%'))[0]
      assert response_data[0] in reasons
      assert response_data[1] in suggestions
    dashboard_page.logout()

    # log back in as editorial user and validate status display on card
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    workflow_page.click_card('invite_reviewers')
    time.sleep(3)
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.card_ready()
    invite_reviewers.validate_response(reviewer_login, invite_response,response_data[0],
                                       response_data[1])

  def test_core_invite_email_template_edit(self):
    """
    Validates persistence of edits made to email templates in the invite card
    :return: None
    """
    logging.info('Test Invite Reviewers::email templates')
    # current_path = os.getcwd()
    # User log in and makes a submission
    creator_user = random.choice(users)
    logging.info('logging in as {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    mmt = 'OnlyInitialDecisionCard'
    self.create_article(journal='PLOS Wombat', type_=mmt, random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.close_infobox()
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    # paper_id = manuscript_page.get_paper_id_from_short_doi(short_doi)
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_modal()
    # logout and then login as editor
    manuscript_page.logout()
    editorial_user = random.choice(editorial_users)
    logging.info('logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to workflow
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('invite_reviewers')
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.card_ready()
    invite_reviewers.add_invitee_to_queue(reviewer_login)
    invite_reviewers.add_invitee_to_queue(prod_staff_login)
    invite_reviewers.validate_email_template_edits()

  def test_invited_reviewer_report_state(self):
    """
    test_invited_reviewer_report_state: Validates the elements for report status on the invite reviewers card
    :return: void function
    """
    logging.info('Test Invite Reviewers::Reviewer Report State')
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    mmt = 'OnlyInitialDecisionCard'
    self.create_article(journal='PLOS Wombat', type_=mmt, random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.close_infobox()
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    paper_id = manuscript_page.get_paper_id_from_short_doi(short_doi)
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()

    # login as editorial user
    editorial_user = random.choice(editorial_users)
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('invite_reviewers')
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.card_ready()
    manuscript_title = PgSQL().query('SELECT title '
                                     'FROM papers WHERE short_doi = %s;',
                                     (short_doi,))[0][0]
    manuscript_title = unicode(manuscript_title,
                               encoding='utf-8',
                               errors='strict')
    invite_reviewers.validate_invite(reviewer_login,
                                     mmt,
                                     manuscript_title,
                                     creator_user,
                                     short_doi)
    invite_reviewers.click_close_button()
    workflow_page.logout()

    # login as reviewer respond to invite
    dashboard_page = self.cas_login(email=reviewer_login['email'])
    dashboard_page.page_ready()
    dashboard_page.click_view_invites_button()
    dashboard_page.accept_invitation(manuscript_title)
    # Wait the accept request is ok
    time.sleep(2)
    # logout and enter as editor
    manuscript_page.logout()

    # login as editorial user
    editorial_user = random.choice(editorial_users)
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('invite_reviewers')
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.card_ready()
    invite_reviewers.validate_invited_reviewer_report_state(reviewer_login, 'pending')
    # logout and enter as reviewer
    workflow_page.logout()

    # login as reviewer to review the paper
    dashboard_page = self.cas_login(email=reviewer_login['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    paper_viewer.complete_task('Review by')
    # logout and enter as editor
    manuscript_page.logout()

    # login as editorial user
    editorial_user = random.choice(editorial_users)
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to wf
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('invite_reviewers')
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.card_ready()
    invite_reviewers.validate_invited_reviewer_report_state(reviewer_login,
                                                            'completed')


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
