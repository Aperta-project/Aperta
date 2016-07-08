#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates Paper submission and invite reviewer
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import prod_staff_login, reviewer_login, users, editorial_users
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
    # Abbreviate the timeout for conversion success message
    manuscript_page.validate_ihat_conversions_success(timeout=15)
    # Note: Request title to make sure the required page is loaded
    paper_url = manuscript_page.get_current_url()
    paper_id = paper_url.split('/')[-1]
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    # Giving just a little extra time here so the title on the paper gets updated
    # What I notice is that if we submit before iHat is done updating, the paper title
    # reverts to the temporary title specified on the CNS overlay (5s is too short)
    # APERTA-6514
    time.sleep(15)
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()
    # Set up a handling editor, academic editor and cover editor for this paper

    # self.set_editors_in_db(paper_id)
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
    invite_reviewers.validate_card_elements_styles(paper_id)
    logging.info('Paper id is: {0}.'.format(paper_id))
    manuscript_title = PgSQL().query('SELECT title from papers WHERE id = %s;', (paper_id,))[0][0]
    manuscript_title = unicode(manuscript_title,
                               encoding='utf-8',
                               errors='strict')
    # The title we pass in here must be a unicode object if there is utf-8 data present
    invite_reviewers.validate_invite_reviewer(reviewer_login,
                                              manuscript_title,
                                              creator_user,
                                              paper_id)
    # Invite a second user to invite then delete before acceptance
    invite_reviewers.validate_invite_reviewer(prod_staff_login,
                                              manuscript_title,
                                              creator_user,
                                              paper_id)
    logging.info('Revoking invite for {0}'.format(prod_staff_login['name']))
    invite_reviewers.revoke_invitee(prod_staff_login, 'Reviewer')
    invite_reviewers.click_close_button()
    time.sleep(.5)
    workflow_page.logout()

    # login as reviewer respond to invite
    self.cas_login(email=reviewer_login['email'])
    time.sleep(2)
    dashboard_page.click_view_invites_button()
    invite_response, response_data = dashboard_page.accept_or_reject_invitation(manuscript_title)
    logging.info('Invitees response to review request was {0}'.format(invite_response))
    # If accepted, validate new assignment in db
    wombat_journal_id = PgSQL().query('SELECT id '
                                      'FROM journals '
                                      'WHERE name = \'PLOS Wombat\';')[0][0]
    reviewer_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'areviewer\';')[0][0]
    reviewer_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                      'name = \'Reviewer\';',
                                      (wombat_journal_id,))[0][0]
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
      reasons, suggestions = PgSQL().query('SELECT decline_reason, reviewer_suggestions FROM '
          'invitations WHERE invitee_id = %s AND state=\'rejected\' AND invitee_role '
          '=\'Reviewer\' AND decline_reason LIKE %s AND reviewer_suggestions LIKE %s;',
          (reviewer_user_id, response_data[0]+'%', response_data[1]+'%'))[0]
      assert response_data[0] in reasons
      assert response_data[1] in suggestions
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
