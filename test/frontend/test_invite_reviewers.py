#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import creator_login1, creator_login2, creator_login3, creator_login4, \
    creator_login5, staff_admin_login, internal_editor_login, handling_editor_login, \
    cover_editor_login, prod_staff_login, pub_svcs_login, super_admin_login, \
    reviewer_login
from frontend.common_test import CommonTest
from Cards.invite_reviewer_card import InviteReviewersCard
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

"""
This behavioral test case validates Paper submission and invite reviewer
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
__author__ = 'jgray@plos.org'

users = [creator_login1,
         creator_login2,
         creator_login3,
         creator_login4,
         creator_login5,
         ]

editorial_users = [handling_editor_login,
                   cover_editor_login,
                   internal_editor_login,
                   staff_admin_login,
                   super_admin_login,
                   prod_staff_login,
                   pub_svcs_login,
                   ]


@MultiBrowserFixture
class InviteReviewersCardTest(CommonTest):
  """
  Validate the elements, styles, functions of the Invite Reviewers card
  """

  def test_invite_reviewers_actions(self):
    """
    test_invite_reviewers_card: Validates the elements, styles, roles and functions of invite
      reviewers from new document creation through inviting reviewer, validation of the invite on
      the invitees dashboard, acceptance and rejections
    :return: void function
    """
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat',
                        type_='OnlyInitialDecisionCard',
                        random_bit=True,
                        )
    dashboard_page.restore_timeout()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success()
    # Note: Request title to make sure the required page is loaded
    paper_url = manuscript_page.get_current_url()
    paper_id = paper_url.split('/')[-1]
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))

    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()

    # Set up a handling editor, academic editor and cover editor for this paper
    wombat_journal_id = PgSQL().query('SELECT id FROM journals WHERE name = \'PLOS Wombat\';')[0][0]
    handling_editor_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                                 'name = \'Handling Editor\';',
                                                 (wombat_journal_id,))[0][0]
    cover_editor_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                              'name = \'Cover Editor\';',
                                              (wombat_journal_id,))[0][0]
    academic_editor_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                                 'name = \'Academic Editor\';',
                                                 (wombat_journal_id,))[0][0]

    handedit_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'ahandedit\';')[0][0]
    covedit_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'acoveredit\';')[0][0]
    acadedit_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'aacadedit\';')[0][0]

    PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                   'created_at, updated_at) VALUES (%s, %s, %s, \'Paper\', now(), now());',
                   (handedit_user_id, handling_editor_role_for_env, paper_id))
    PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                   'created_at, updated_at) VALUES (%s, %s, %s, \'Paper\', now(), now());',
                   (covedit_user_id, cover_editor_role_for_env, paper_id))
    PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                   'created_at, updated_at) VALUES (%s, %s, %s, \'Paper\', now(), now());',
                   (acadedit_user_id, academic_editor_role_for_env, paper_id))

    # login as editorial user
    editorial_user = random.choice(editorial_users)
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    paper_workflow_url = '{0}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    # go to card
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the workflow page to load and for the elements to attach to DOM,
    #   otherwise failures
    time.sleep(10)
    workflow_page.click_card('invite_reviewers')
    time.sleep(3)
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.validate_card_elements_styles()
    manuscript_title = PgSQL().query('SELECT title from papers WHERE id = %s;', (paper_id,))[0][0]
    logging.info(manuscript_title)
    invite_reviewers.validate_invite_reviewer(reviewer_login,
                                              manuscript_title,
                                              creator_user,
                                              paper_id)
    invite_reviewers.click_close_button()
    time.sleep(.5)
    workflow_page.logout()

    # login as reviewer respond to invite
    self.cas_login(email=reviewer_login['email'])
    time.sleep(2)
    dashboard_page.click_view_invites_button()
    invite_response = dashboard_page.accept_or_reject_invitation(manuscript_title)
    logging.info('Invitees response to review request was {0}'.format(invite_response))
    # If accepted, validate new assignment in db
    if invite_response == 'Accept':
      reviewer_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'areviewer\';')[0][0]
      reviewer_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                            'name = \'Reviewer\';',
                                            (wombat_journal_id,))[0][0]
      test_for_role = PgSQL().query('SELECT role_id FROM assignments WHERE user_id = %s '
                                    'AND assigned_to_type=\'Paper\' and assigned_to_id = %s;',
                                    (reviewer_user_id, paper_id))[0][0]
      assert test_for_role == reviewer_role_for_env, 'assigned role, {0}, is not the expected ' \
                                                     'value: {1}'.format(test_for_role,
                                                                         reviewer_role_for_env)
    workflow_page.logout()

    # log back in as editorial user and validate status display on card
    logging.info(editorial_user)
    self.cas_login(email=editorial_user['email'])
    paper_workflow_url = '{0}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    # go to card
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the workflow page to load and for the elements to attach to DOM,
    #   otherwise failures
    time.sleep(10)
    workflow_page.click_card('invite_reviewers')
    time.sleep(3)
    invite_reviewers = InviteReviewersCard(self.getDriver())
    invite_reviewers.validate_reviewer_response(reviewer_login, invite_response)

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
