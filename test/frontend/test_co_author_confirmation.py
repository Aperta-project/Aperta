#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This test case validates the Authors Task.
"""

import logging
import os
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users
from frontend.Cards.authors_card import AuthorsCard
from frontend.Tasks.authors_task import AuthorsTask
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.correspondence_history import CorrespondenceHistory
from .Pages.workflow_page import WorkflowPage
from frontend.common_test import CommonTest
from Base.Resources import editorial_users, prod_staff_login

__author__ = 'achoe@plos.org'

editorial_users.remove(prod_staff_login)

@MultiBrowserFixture
class CoAuthorConfirmationTest(CommonTest):
    """
    Validates the functions of the coauthor confirmation status for both individual
    and group authors.
    """
    def test_individual_coauthor_confirmation_email(self):
        """
        Validates the function of the co-author confirmation email feature.
        Note: Since we do not currently have a means of validating an email sent
        via Aperta, this test will rely on the correspondence history page. This
        means that this test will be limited in that we will not be able to update
        co-author status via email through this test. Validation will instead focus
        on the different element of the co-author confirmation email (text, links, etc.).
        Once we have testable emails configured, we will need to update this test accordingly.
        :return: None
        """
        logging.info('Test Co-author Confirmation::individual_co_author_confirmation_email')
        current_path = os.getcwd()
        logging.info(current_path)
        # Users logs in and make a submission
        creator_user = random.choice(users)
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.page_ready()
        dashboard_page.click_create_new_submission_button()
        # We need an mmt that has an Authors card - will choose Research for now.
        mmt = 'Research'
        self.create_article(title='testing individual coauthor confirmation email',
                            journal='PLOS Wombat', type_=mmt, random_bit=True)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready_post_create()
        short_doi = manuscript_page.get_paper_short_doi_from_url()
        manuscript_page.complete_task('Upload Manuscript')
        manuscript_page.complete_task('Title And Abstract')
        manuscript_page.complete_task('Cover Letter')
        manuscript_page.complete_task('Figures')
        manuscript_page.complete_task('Supporting Info')
        manuscript_page.complete_task('Additional Information')
        manuscript_page.complete_task('Early Version')
        # Now, on the Authors card, we add a co-author
        manuscript_page.click_task('Authors')
        authors_task = AuthorsTask(self.getDriver())
        authors_task.task_ready()
        authors_task.add_individual_author_task_action()
        authors_task.edit_author(creator_user)
        manuscript_page.click_submit_btn()
        manuscript_page.confirm_submit_btn()
        manuscript_page.close_modal()

        # logout and login as a staff user
        manuscript_page.logout()
        staff_user = random.choice(editorial_users)
        logging.info('Logging in as {0}'.format(staff_user))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        dashboard_page.go_to_manuscript(short_doi)
        self._driver.navigated = True
        paper_viewer = ManuscriptViewerPage(self.getDriver())
        paper_viewer.page_ready()

        # go to Correspondence History
        paper_viewer.click_correspondence_link()
        correspondence_page = CorrespondenceHistory(self.getDriver())
        correspondence_page.page_ready()
        correspondence_page.validate_co_author_confirmation_email()

    def test_group_coauthor_confirmation_email(self):
        """
        Validates the function of the co-author confirmation email feature.
        Note: Since we do not currently have a means of validating an email sent
        via Aperta, this test will rely on the correspondence history page. This
        means that this test will be limited in that we will not be able to update
        co-author status via email through this test. Validation will instead focus
        on the different element of the co-author confirmation email (text, links, etc.).
        Once we have testable emails configured, we will need to update this test accordingly.
        :return: None
        """
        logging.info('Test Co-author Confirmation::individual_co_author_confirmation_email')
        current_path = os.getcwd()
        logging.info(current_path)
        # Users logs in and make a submission
        creator_user = random.choice(users)
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.page_ready()
        dashboard_page.click_create_new_submission_button()
        # We need an mmt that has an Authors card - will choose Research for now.
        mmt = 'Research'
        self.create_article(title='testing group coauthor confirmation email',
                            journal='PLOS Wombat', type_=mmt, random_bit=True)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready_post_create()
        short_doi = manuscript_page.get_paper_short_doi_from_url()
        manuscript_page.complete_task('Upload Manuscript')
        manuscript_page.complete_task('Title And Abstract')
        manuscript_page.complete_task('Ethics Statement')
        manuscript_page.complete_task('Cover Letter')
        manuscript_page.complete_task('Figures')
        manuscript_page.complete_task('Reviewer Candidates')
        manuscript_page.complete_task('Supporting Info')
        manuscript_page.complete_task('Competing Interests')
        manuscript_page.complete_task('Financial Disclosure')
        manuscript_page.complete_task('Additional Information')
        manuscript_page.complete_task('Early Version')
        # Now, on the Authors card, we add a co-author
        manuscript_page.click_task('Authors')
        authors_task = AuthorsTask(self.getDriver())
        authors_task.add_group_author_task_action()
        authors_task.edit_author(creator_user)
        manuscript_page.click_submit_btn()
        manuscript_page.confirm_submit_btn()
        manuscript_page.close_modal()

        # logout and login as a staff user
        manuscript_page.logout()
        staff_user = random.choice(editorial_users)
        logging.info('Logging in as {0}'.format(staff_user))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        dashboard_page.go_to_manuscript(short_doi)
        self._driver.navigated = True
        paper_viewer = ManuscriptViewerPage(self.getDriver())
        paper_viewer.page_ready()

        # go to Correspondence History
        paper_viewer.click_correspondence_link()
        correspondence_page = CorrespondenceHistory(self.getDriver())
        correspondence_page.page_ready()
        correspondence_page.validate_co_author_confirmation_email()

    def test_individual_coauthor_confirmation_by_staff(self):
        """
        Validates the ability of a staff user to confirm or refute individual co-authorship status
        in the UI.
        :return: void function
        """
        logging.info('Test Co-author Confirmation::individual_coauthor_confirmation_by_staff')
        current_path = os.getcwd()
        logging.info(current_path)
        # Users logs in and make a submission
        creator_user = random.choice(users)
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.page_ready()
        dashboard_page.click_create_new_submission_button()
        # We need an mmt that has an Authors card - will choose Research for now.
        mmt = 'Research'
        self.create_article(title='testing individual coauthor confirmation by staff',
                            journal='PLOS Wombat', type_=mmt, random_bit=True)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready_post_create()
        short_doi = manuscript_page.get_paper_short_doi_from_url()
        manuscript_page.complete_task('Upload Manuscript')
        manuscript_page.complete_task('Title And Abstract')
        manuscript_page.complete_task('Cover Letter')
        manuscript_page.complete_task('Figures')
        manuscript_page.complete_task('Supporting Info')
        manuscript_page.complete_task('Additional Information')
        manuscript_page.complete_task('Early Version')
        # Now, on the Authors card, we add a co-author
        manuscript_page.click_task('Authors')
        authors_task = AuthorsTask(self.getDriver())
        authors_task.task_ready()
        authors_task.add_individual_author_task_action()
        authors_task.edit_author(creator_user)
        manuscript_page.click_submit_btn()
        manuscript_page.confirm_submit_btn()
        manuscript_page.close_modal()

        # Now that we've submitted the manuscript, the coauthor confirmation controls are now
        # available to staff users. However, authors should not be able to see this, per AC 1.1 of
        # APERTA-9300.
        # Here, we'll open the authors card, and validate that the coauthor confirmation elements
        # are not available to the currently logged in author:
        authors_task.validate_coauthors_elements_absence()

        # logout and login as a staff user
        manuscript_page.logout()
        staff_user = random.choice(editorial_users)
        logging.info('Logging in as {0}'.format(staff_user))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        dashboard_page.go_to_manuscript(short_doi)
        self._driver.navigated = True
        paper_viewer = ManuscriptViewerPage(self.getDriver())
        paper_viewer.page_ready()

        # go to workflow
        paper_viewer.click_workflow_link()
        workflow_page = WorkflowPage(self.getDriver())
        workflow_page.page_ready()
        workflow_page.click_authors_card()

        authors_card = AuthorsCard(self.getDriver())
        authors_card.click_completion_button()
        authors_card.validate_coauthor_status('individual', short_doi)

    def test_group_coauthor_confirmation_by_staff(self):
        """
        Validates the ability of a staff user to confirm or refute group co-authorship status
        in the UI.
        :return: void function
        """
        logging.info('Test Co-author Confirmation::group_coauthor_confirmation_by_staff')
        current_path = os.getcwd()
        logging.info(current_path)
        # Users logs in and make a submission
        creator_user = random.choice(users)
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.page_ready()
        dashboard_page.click_create_new_submission_button()
        # We need an mmt that has an Authors card - will choose Research for now.
        mmt = 'Research'
        self.create_article(title='testing group coauthor confirmation by staff',
                            journal='PLOS Wombat', type_=mmt, random_bit=True)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready_post_create()
        short_doi = manuscript_page.get_paper_short_doi_from_url()
        manuscript_page.complete_task('Upload Manuscript')
        manuscript_page.complete_task('Title And Abstract')
        manuscript_page.complete_task('Cover Letter')
        manuscript_page.complete_task('Figures')
        manuscript_page.complete_task('Supporting Info')
        manuscript_page.complete_task('Additional Information')
        manuscript_page.complete_task('Early Version')
        # Now, on the Authors card, we add a co-author
        manuscript_page.click_task('Authors')
        authors_task = AuthorsTask(self.getDriver())
        authors_task.task_ready()
        authors_task.add_group_author_task_action()
        authors_task.edit_author(creator_user)
        manuscript_page.click_submit_btn()
        manuscript_page.confirm_submit_btn()
        manuscript_page.close_modal()

        # Now that we've submitted the manuscript, the coauthor confirmation controls are now
        # available to staff users. However, authors should not be able to see this, per AC 1.1 of
        # APERTA-9300.
        # Here, we'll open the authors card, and validate that the coauthor confirmation elements
        # are not available to the currently logged in author:
        authors_task.validate_coauthors_elements_absence()

        # logout and login as a staff user
        manuscript_page.logout()
        staff_user = random.choice(editorial_users)
        logging.info('Logging in as {0}'.format(staff_user))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        dashboard_page.go_to_manuscript(short_doi)
        self._driver.navigated = True
        paper_viewer = ManuscriptViewerPage(self.getDriver())
        paper_viewer.page_ready()

        # go to workflow
        paper_viewer.click_workflow_link()
        workflow_page = WorkflowPage(self.getDriver())
        workflow_page.page_ready()
        workflow_page.click_authors_card()

        authors_card = AuthorsCard(self.getDriver())
        authors_card.click_completion_button()
        authors_card.validate_coauthor_status('group', short_doi)


if __name__ == '__main__':
    CommonTest.run_tests_randomly()
