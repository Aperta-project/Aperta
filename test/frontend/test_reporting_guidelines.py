#! /usr/bin/env python2
# -*- coding: utf-8 -*-

import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from Tasks.reporting_guidelines_task import ReportingGuidelinesTask

__author__ = 'achoe@plos.org'

@MultiBrowserFixture
class ReportingGuidelinesTaskTest(CommonTest):
  def test_smoke_reporting_guidelines_styles(self):
    """
    test_reporting_guidelines: Validates the elements, styles of the Reporting Guidelines task and
    card from new document creation through workflow view
    """
    logging.info('Test Reporting Guidelines::styles')
    # User logs in and makes a submission:
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Reporting Guidelines test', journal='PLOS Wombat',
                        type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    short_doi = manuscript_page.get_short_doi()
    # Reporting Guidelines
    manuscript_page.click_task('reporting_guidelines')
    reporting_guidelines_task = ReportingGuidelinesTask(self.getDriver())
    reporting_guidelines_task.task_ready()
    reporting_guidelines_task.validate_styles()
    reporting_guidelines_task.click_completion_button()
    reporting_guidelines_task.logout()

    # login as a privileged user to validate the presentation of the Reporting Guidelines card.


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
