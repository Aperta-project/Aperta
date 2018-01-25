#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This test case validates style and function of Competing Interests Card in both paper viewer and
    workflow contexts. It also validates the discussion function of the card in workflow view and
    integration with the Recent Activity feeds in both contexts. Additionally, it validates the
    ident used to store the competing interests question so the answer is appropriately isolated
    for export to Apex - where it is a required element.

"""
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
from frontend.Cards.competing_interests import CompetingInterestsCard
from frontend.Cards.register_decision_card import RegisterDecisionCard
from frontend.Tasks.competing_interests import CompetingInterestsTask
from frontend.common_test import CommonTest
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.workflow_page import WorkflowPage

__author__ = 'gholmes@plos.org'


@MultiBrowserFixture
class CompetingInterestsCardTest(CommonTest):
    """
    Validate the elements, styles, functions of the Competing Interest card including integration
        with the Recent Activity Feed in both Paper Viewer and Workflow contexts. Validates data
        collection for Export to Apex
    """

    def test_smoke_ci_styles_elements(self):
        """
        Validates the elements, styles of the Competing Interests card in both Paper Viewer and
            Workflow contexts, sets the Yes radio button in paper viewer context to display the
            input sub-form and enters a basic reason. Validates those values in workflow view.
            Intrinsically validates the use of the correct ident for the key data.
        :return: void function
        """
        logging.info('Test Competing interests::styles and elements')
        # Users logs in and completes the task
        creator_user = random.choice(users)
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.page_ready()
        dashboard_page.click_create_new_submission_button()
        self.create_article(title='Competing Interests Elements and Styles Test',
                            journal='PLOS Wombat',
                            type_='generateCompleteApexData',
                            random_bit=True)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready_post_create()
        short_doi = manuscript_page.get_short_doi()
        # Validate Elements and Styles for Paper Viewer context
        manuscript_page.click_task('Competing Interests')
        ci_task = CompetingInterestsTask(self.getDriver())
        ci_task.task_ready()
        # The following method call leaves the card in a state where the Yes radio is selected
        ci_task.validate_styles()
        ci_task.validate_common_elements_styles()
        ci_task.logout()

        # login as privileged user to validate the presentation of the data on the CI Card
        staff_user = random.choice(editorial_users)
        logging.info('Logging in as user: {0}'.format(staff_user['name']))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        dashboard_page.go_to_manuscript(short_doi)
        self._driver.navigated = True
        paper_viewer = ManuscriptViewerPage(self.getDriver())
        paper_viewer.page_ready()
        # go to wf
        paper_viewer.click_workflow_link()
        workflow_page = WorkflowPage(self.getDriver())
        workflow_page.page_ready()
        workflow_page.click_competing_interest_card()
        ci_card = CompetingInterestsCard(self.getDriver())
        ci_card.card_ready()
        ci_card.validate_styles(selected='Yes')
        # APERTA-12445 Permission to add participants is not exposed/configured so there is a
        #     failure of the following call
        # ci_card.validate_common_elements_styles(short_doi)

    def test_core_ci_selection(self):
        """
        Validates setting and saving the selection state and competing interests statement
        :return: void function
        """
        logging.info('Competing Interests::selection and saving')
        # Users logs in and completes the task
        creator_user = random.choice(users)
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.page_ready()
        dashboard_page.click_create_new_submission_button()
        self.create_article(title='Competing Interests selection and saving',
                            journal='PLOS Wombat',
                            type_='generateCompleteApexData',
                            random_bit=True)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready_post_create()
        short_doi = manuscript_page.get_short_doi()
        # Complete the card in Paper Viewer context as author
        manuscript_page.click_task('Competing Interests')
        ci_task = CompetingInterestsTask(self.getDriver())
        ci_task.task_ready()
        choice, ci_statement = ci_task.complete_form('')
        ci_task.click_completion_button()
        # Test for task completion in the activity feed
        manuscript_page.open_recent_activity()
        ci_task.validate_recent_activity_entry('Competing Interests card was marked as complete',
                                               creator_user['name'])
        manuscript_page.close_overlay()
        ci_task.logout()

        # login as privileged user to validate the presentation of the data on the CI Card
        staff_user = random.choice(editorial_users)
        logging.info('Logging in as user: {0}'.format(staff_user['name']))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        dashboard_page.go_to_manuscript(short_doi)
        self._driver.navigated = True
        paper_viewer = ManuscriptViewerPage(self.getDriver())
        paper_viewer.page_ready()
        # go to wf
        paper_viewer.click_workflow_link()
        workflow_page = WorkflowPage(self.getDriver())
        workflow_page.page_ready()
        workflow_page.click_competing_interest_card()
        ci_card = CompetingInterestsCard(self.getDriver())
        ci_card.card_ready()
        # Mark card incomplete
        ci_card.click_completion_button()
        ci_card.validate_state(choice, ci_statement)
        # remark card complete
        ci_card.click_completion_button()
        ci_card.click_close_button()
        # There is the slightest animation on closure, so inserting a pause here ensures we
        #     open the recent activity overlay correctly after.
        ci_card.pause_to_save()
        # Test for task completion in the activity feed
        workflow_page.open_recent_activity()
        ci_card.validate_recent_activity_entry('Competing Interests card was marked as incomplete',
                                               staff_user['name'])
        ci_card.validate_recent_activity_entry('Competing Interests card was marked as complete',
                                               staff_user['name'])
        workflow_page.close_overlay()
        workflow_page.pause_to_save()
        workflow_page.click_competing_interest_card()
        ci_card.card_ready()
        # Finally, mark card incomplete to make changes
        ci_card.click_completion_button()
        choice, content = ci_card.complete_form('')
        ci_card.validate_state(choice, content)
        # And re-complete when we are all done
        ci_card.click_completion_button()

    def test_full_ci_diff_view(self):
        """
        Validates the versions view of the competing interests statement
        :return: void function
        """
        logging.info('Competing Interests::selection and saving')
        # Users logs in and completes the task
        creator_user = random.choice(users)
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.page_ready()
        dashboard_page.click_create_new_submission_button()
        self.create_article(title='Competing Interests Versions View',
                            journal='PLOS Wombat',
                            type_='generateCompleteApexData',
                            random_bit=True)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready_post_create()
        short_doi = manuscript_page.get_short_doi()
        # Complete the card in Paper Viewer context as author
        manuscript_page.click_task('Competing Interests')
        ci_task = CompetingInterestsTask(self.getDriver())
        ci_task.task_ready()
        choice, ci_statement = ci_task.complete_form('')
        ci_task.click_completion_button()
        manuscript_page.click_task('Competing Interests')
        manuscript_page.complete_task('Additional Information')
        manuscript_page.complete_task('Authors', author=creator_user)
        manuscript_page.complete_task('Billing')
        manuscript_page.complete_task('Cover Letter')
        manuscript_page.complete_task('Data Availability')
        manuscript_page.complete_task('Early Version')
        manuscript_page.complete_task('Ethics Statement')
        manuscript_page.complete_task('Figures')
        manuscript_page.complete_task('Financial Disclosure')
        manuscript_page.complete_task('New Taxon')
        manuscript_page.complete_task('Reporting Guidelines')
        manuscript_page.complete_task('Reviewer Candidates')
        manuscript_page.complete_task('Supporting Info')
        manuscript_page.complete_task('Upload Manuscript')
        manuscript_page.complete_task('Title And Abstract')
        manuscript_page.click_submit_btn()
        manuscript_page.confirm_submit_btn()
        manuscript_page.page_ready()
        manuscript_page.close_modal()
        manuscript_page.logout()
        # Enter as Editorial User
        editorial_user = random.choice(editorial_users)
        logging.info(editorial_user)
        dashboard_page = self.cas_login(email=editorial_user['email'])
        dashboard_page.page_ready()
        dashboard_page.go_to_manuscript(short_doi)
        self._driver.navigated = True
        paper_viewer = ManuscriptViewerPage(self.getDriver())
        paper_viewer.page_ready()
        # go to workflow and open Register Decision Card
        paper_viewer.click_workflow_link()
        workflow_page = WorkflowPage(self.getDriver())
        workflow_page.page_ready()
        workflow_page.click_card('register_decision')
        register_decision = RegisterDecisionCard(self.getDriver())
        register_decision.register_decision('Minor Revision')
        # Time needed to proceed after closing the RegisterDecisionCard
        time.sleep(3)
        workflow_page.logout()
        # Log back in now as the creator/author and make changes to the Competing Interests card
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.page_ready()
        dashboard_page.go_to_manuscript(short_doi)
        self._driver.navigated = True
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready()
        manuscript_page.click_task('Competing Interests')
        ci_task = CompetingInterestsTask(self.getDriver())
        ci_task.task_ready()
        # Mark the task incomplete in order to make changes
        ci_task.click_completion_button()
        new_choice, new_ci_statement = ci_task.complete_form('')
        # Close Task
        manuscript_page.click_task('Competing Interests')
        # Go into Versions view - compare 0.0 to current draft
        manuscript_page.select_manuscript_version_item('compare', 1)
        manuscript_page._wait_for_element(manuscript_page._get(
            manuscript_page._paper_sidebar_diff_icons))
        paper_diff = ManuscriptViewerPage(self.getDriver())
        paper_diff.click_task('Competing Interests')
        ci_task = CompetingInterestsTask(self.getDriver())
        ci_task.diff_view_ready()
        ci_task.validate_diffed_text(choice, new_choice)
        ci_task.validate_diffed_tinymce_text(ci_statement, new_ci_statement)


if __name__ == '__main__':
    CommonTest.run_tests_randomly()
