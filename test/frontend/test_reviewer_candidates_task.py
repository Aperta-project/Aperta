#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates the reviewer candidates task and card.
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted into
    frontend/assets/
"""

import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage
from Tasks.reviewer_candidates_task import ReviewerCandidatesTask

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class ReviewerCandidatesTaskTest(CommonTest):
  """
  1. Creator can recommend or oppose a reviewer
  """

  def test_smoke_reviewer_candidates_styles(self):
    """
    test_reviewer_candidates_task: Validates the elements, styles and functions of the reviewer
      candidates task and card from new document creation through making a recommendation through
      view of that data on the reviewer candidates card
    :return: void function
    """
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat',
                        type_='generateCompleteApexData',
                        random_bit=True,
                        title='Reviewer Candidates Test'
                        )
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    dashboard_page.restore_timeout()
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(timeout=15)
    # Note: Request title to make sure the required page is loaded
    manuscript_page.get_paper_db_id()
    time.sleep(2)
    # figures
    manuscript_page.click_task('review_candidates')
    time.sleep(3)
    rev_cand_task = ReviewerCandidatesTask(self.getDriver())
    time.sleep(1)
    rev_cand_task.validate_styles()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
