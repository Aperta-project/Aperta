#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates Paper submission and assign team
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users, handling_editor_login, cover_editor_login, \
    academic_editor_login
from frontend.common_test import CommonTest
from .Cards.assign_team_card import AssignTeamCard
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.workflow_page import WorkflowPage

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class AssignTeamCardTest(CommonTest):
    """
    Validate the elements, styles, functions of the Assign Team card
    """

    def test_smoke_assign_team_actions(self):
        """
        test_assign_team_card: Validates the elements, styles, roles and functions of assign team
            card from new document creation through inviting reviewer, academic editor, cover and
            handling editor
        :return: void function
        """
        logging.info('Test Assign Team::actions')
        current_path = os.getcwd()
        logging.info(current_path)
        # Users logs in and make a submission
        creator_user = random.choice(users)
        reviewer_user = self.pick_reviewer()
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.set_timeout(60)
        dashboard_page.click_create_new_submission_button()
        self.create_article(title='Test Assign Team Actions',
                            journal='PLOS Wombat',
                            type_='OnlyInitialDecisionCard',
                            random_bit=True)
        dashboard_page.restore_timeout()
        # Time needed for iHat conversion. This is not quite enough time in all circumstances
        time.sleep(5)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready_post_create()
        paper_url = manuscript_page.get_current_url_without_args()
        short_doi = manuscript_page.get_paper_short_doi_from_url()
        manuscript_page.complete_task('Upload Manuscript')
        manuscript_page.complete_task('Title And Abstract')
        manuscript_page.click_submit_btn()
        manuscript_page.confirm_submit_btn()
        # Now we get the submit confirmation overlay - Sadly, we take time to switch the overlay
        time.sleep(2)
        manuscript_page.close_modal()
        # logout and enter as editor
        manuscript_page.logout()

        # login as editorial user
        editorial_user = random.choice(editorial_users)
        logging.info(editorial_user)
        self.cas_login(email=editorial_user['email'])
        paper_workflow_url = '{0}/workflow'.format(paper_url)
        self._driver.get(paper_workflow_url)
        workflow_page = WorkflowPage(self.getDriver())
        workflow_page.page_ready()
        workflow_page.click_card('assign_team')
        assign_team = AssignTeamCard(self.getDriver())
        assign_team.card_ready()
        assign_team.validate_card_elements_styles(short_doi)
        assign_team.assign_role(academic_editor_login, 'Academic Editor')
        assign_team.assign_role(cover_editor_login, 'Cover Editor')
        assign_team.assign_role(handling_editor_login, 'Handling Editor')
        assign_team.assign_role(reviewer_user, 'Reviewer')
        assign_team.revoke_assignment(academic_editor_login, 'Academic Editor')
        assign_team.revoke_assignment(reviewer_user, 'Reviewer')

    if __name__ == '__main__':
        CommonTest.run_tests_randomly()
