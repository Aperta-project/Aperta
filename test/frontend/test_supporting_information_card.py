#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates style and function of the Supporting Information (SI) Card
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import os
import random

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'sbassi@plos.org'

@MultiBrowserFixture
class SICardTest(CommonTest):
  """
  Validate the elements, styles, functions of the Revision Tech Check card
  """

  def test_si_card(self):
    """
    test_si_card: Validates the elements, styles, and functions of RTC Card
    :return: void function
    """
    logging.info('Test SICard')
    creator_user = random.choice(users)
    logging.info(creator_user)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_id = manuscript_page.get_paper_id_from_url()
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    manuscript_page.complete_task('Supporting Info')
    import pdb; pdb.set_trace()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
