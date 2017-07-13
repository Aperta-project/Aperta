#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates Paper submission and invite Academic Editor (AE)
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import random
import time
import six

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import academic_editor_login, users, editorial_users, pub_svcs_login
from frontend.common_test import CommonTest
from .Cards.invite_ae_card import InviteAECard
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.workflow_page import WorkflowPage

__author__ = 'sbassi@plos.org'


@MultiBrowserFixture
class InviteAECardTest(CommonTest):
  """
  Validate the elements, styles, functions of the Invite AE card
  """

  def test_invite_ae_card(self):
    """
    test_invite_ae: Validates the elements, styles, roles and functions of invite academic editors
    from new document creation through inviting ae, validation of the invite on the invitees
    dashboard, acceptance and rejections
    :return: void function
    """
    logging.info('Test Invite AE')
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    mmt = 'OnlyInitialDecisionCard'
    self.create_article(journal='PLOS Wombat', type_=mmt, random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_url = manuscript_page.get_current_url()
    short_doi = manuscript_page.get_short_doi()
    paper_id = manuscript_page.get_paper_id_from_short_doi(short_doi)
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()

    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    paper_workflow_url = '{0}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    # add card invite AE with add new card
    # Check if card is there
    if not workflow_page.is_card('Invite Academic Editor'):
      workflow_page.add_card('Invite Academic Editor')
    # click on invite academic editor
    workflow_page.click_card('invite_academic_editor')
    invite_ae_card = InviteAECard(self.getDriver())
    invite_ae_card.card_ready()
    invite_ae_card.validate_card_elements_styles(academic_editor_login, 'ae', short_doi)
    manuscript_title = PgSQL().query('SELECT title '
                                     'FROM papers WHERE short_doi = %s;', (short_doi,))[0][0]

    manuscript_title = six.u(manuscript_title)

    # The title we pass in here must be a unicode object if there is utf-8 data present
    invite_ae_card.validate_invite(academic_editor_login,
                                   mmt,
                                   manuscript_title,
                                   creator_user,
                                   short_doi)
    # Invite a second user to delete
    invite_ae_card.validate_invite(pub_svcs_login,
                                   mmt,
                                   manuscript_title,
                                   creator_user,
                                   short_doi)
    logging.info('Revoking invite for {0}'.format(pub_svcs_login['name']))
    invite_ae_card.revoke_invitee(pub_svcs_login, 'Academic Editor')
    time.sleep(.5)
    workflow_page.logout()

    dashboard_page = self.cas_login(email=academic_editor_login['email'])
    dashboard_page.page_ready()
    dashboard_page.click_view_invites_button()
    # AE accepts or declines invite
    invite_response, response_data = dashboard_page.accept_or_reject_invitation(manuscript_title)
    logging.info('Invitees response to review request was {0}'.format(invite_response))
    # If accepted, validate new assignment in db
    wombat_journal_id = PgSQL().query('SELECT id FROM journals '
                                      'WHERE name = \'PLOS Wombat\';')[0][0]
    ae_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'aacadedit\';')[0][0]
    ae_role_for_env = PgSQL().query('SELECT id FROM roles '
                                    'WHERE journal_id = %s '
                                    'AND name = \'Academic Editor\';', (wombat_journal_id,))[0][0]
    try:
      test_for_role = PgSQL().query('SELECT role_id FROM assignments WHERE user_id = %s '
                                    'AND assigned_to_type=\'Paper\' and assigned_to_id = %s;',
                                    (ae_user_id, paper_id))[0][0]
    except IndexError:
      test_for_role = False
    assert invite_response in ['Accept', 'Decline']
    if invite_response == 'Accept':
      assert test_for_role == ae_role_for_env, 'assigned role, {0}, is not the expected ' \
        'value: {1}'.format(test_for_role, ae_role_for_env)
    elif invite_response == 'Decline':
      assert not test_for_role
      # search for reply, if reply includes null values, don't validate reasons/suggestions
      skip_validation = False
      try:
        reasons, suggestions = PgSQL().query('SELECT decline_reason, reviewer_suggestions '
                                             'FROM invitations '
                                             'WHERE invitee_id = %s '
                                             'AND state=\'declined\' '
                                             'AND invitee_role =\'Academic Editor\' '
                                             'AND decline_reason LIKE %s '
                                             'AND reviewer_suggestions LIKE %s;',
                                             (ae_user_id,
                                              response_data[0]+'%',
                                              response_data[1]+'%'))[0]
      except IndexError:
        logging.info('Either the response reason, academic editor suggestions, or both are blank')
        skip_validation = True
      if not skip_validation:
        assert response_data[0] in reasons
        assert response_data[1] in suggestions
    dashboard_page.logout()

    # log back in as editorial user and validate status display on card
    logging.info(editorial_user)
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    paper_workflow_url = '{0}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    # go to card
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('invite_academic_editor')
    invite_ae_card = InviteAECard(self.getDriver())
    invite_ae_card.card_ready()
    invite_ae_card.validate_response(academic_editor_login,
                                     invite_response,
                                     response_data[0],
                                     response_data[1])

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
