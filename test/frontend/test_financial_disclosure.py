#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This behavioral test case validates the financial disclosure task and card.
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted into
    frontend/assets/
"""

import logging
import random

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
from .Cards.financial_disclosure import FinancialDisclosureCard
from frontend.common_test import CommonTest
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.workflow_page import WorkflowPage
from .Tasks.financial_disclosure import FinancialDisclosureTask

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class FinancialDisclosureTest(CommonTest):
    """
    Tests for the cards and functions for specifying financial disclosure of funders of a manuscript
    """

    def test_smoke_findisc_styles(self):
        """
        Validates the elements, styles of the Financial Disclosure card in both accordion and
            workflow views.
        :return: void function
        """
        logging.info('Test Financial Disclosure::styles')
        # Users logs in and make a submission
        creator_user = random.choice(users)
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.page_ready()
        dashboard_page.click_create_new_submission_button()
        self.create_article(title='Financial Disclosure Element and Styles Test',
                            journal='PLOS Wombat',
                            type_='generateCompleteApexData',
                            random_bit=True)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready_post_create()
        short_doi = manuscript_page.get_short_doi()
        # figures
        manuscript_page.click_task('Financial Disclosure')
        findisc_task = FinancialDisclosureTask(self.getDriver())
        findisc_task.task_ready()
        findisc_task.validate_styles()
        findisc_task.click_completion_button()
        findisc_task.logout()

        # login as privileged user to validate the presentation of the data on the FD Card
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
        workflow_page.click_card('financial_disclosure')
        findisc_card = FinancialDisclosureCard(self.getDriver())
        findisc_card.card_ready()
        findisc_card.validate_styles()

    def test_core_findisc_function(self):
        """
        Validates specifying and saving one or more financial disclosure statements
        :return: void function
        """
        logging.info('Test Financial Disclosure::function')
        # Users logs in and make a submission
        creator_user = random.choice(users)
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.page_ready()
        dashboard_page.click_create_new_submission_button()
        self.create_article(title='Financial Disclosure Function Test',
                            journal='PLOS Wombat',
                            type_='generateCompleteApexData',
                            random_bit=True)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready_post_create()
        short_doi = manuscript_page.get_short_doi()
        # figures
        manuscript_page.click_task('Financial Disclosure')
        findisc_task = FinancialDisclosureTask(self.getDriver())
        findisc_task.task_ready()
        selection_state = findisc_task.complete_form()
        findisc_task.click_completion_button()
        findisc_task.logout()

        # login as privileged user to validate the presentation of the data on the Financial
        #     Disclosure Card
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
        workflow_page.click_card('early_version')
        findisc_card = FinancialDisclosureCard(self.getDriver())
        findisc_card.card_ready()
        findisc_card.validate_state(selection_state=selection_state)


if __name__ == '__main__':
    CommonTest.run_tests_randomly()
