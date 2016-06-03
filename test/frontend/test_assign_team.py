#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates Paper submission and assign team
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import creator_login1, creator_login2, creator_login3, creator_login4, \
    creator_login5, staff_admin_login, internal_editor_login, handling_editor_login, \
    cover_editor_login, prod_staff_login, pub_svcs_login, super_admin_login, \
    reviewer_login, academic_editor_login
from frontend.common_test import CommonTest
from Cards.assign_team_card import AssignTeamCard
from Cards.basecard import users, editorial_users, external_editorial_users
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class AssignTeamCardTest(CommonTest):
  """
  Validate the elements, styles, functions of the Assign Team card
  """

  def test_assign_team_actions(self):
    """
    test_assign_team_card: Validates the elements, styles, roles and functions of assign team card
      from new document creation through inviting reviewer, academic editor, cover and handling
      editor
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
    # Abbreviating the timeout for success message
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
    workflow_page.click_card('assign_team')
    time.sleep(3)
    assign_team = AssignTeamCard(self.getDriver())
    assign_team.validate_card_elements_styles()
    assign_team.assign_role(academic_editor_login, 'Academic Editor')
    assign_team.assign_role(cover_editor_login, 'Cover Editor')
    assign_team.assign_role(handling_editor_login, 'Handling Editor')
    assign_team.assign_role(reviewer_login, 'Reviewer')
    assign_team.revoke_assignment(academic_editor_login, 'Academic Editor')
    assign_team.revoke_assignment(reviewer_login, 'Reviewer')

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
