#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage
from Base.Resources import login_valid_pw, creator_login3, staff_admin_login, internal_editor_login

"""
This test case validates metadata versioning for Aperta.
"""
__author__ = 'sbassi@plos.org'


@MultiBrowserFixture
class MetadataVersioningTest(CommonTest):
  """
  Since metadata versioning is not developed yet, this calls create condition
  for testing by creating an article, filling all required cards, submitting.

  APERTA-5747
  """

  def test_metadata_versioning(self):
    """
    test_metadata_versioning: Validates diffing and versioning functions
      creates, doc, submits, is invited for major revision, makes changes, submits, views diffs
      This is a very long test
    Test metadata versioning (APERTA-5747).
    AC being tested:

    - can see diff comparing submitted versions of metadata, including minor versions
    - Diff Icon in closed card
    - Version Stamp in cards
    - Changed text
    - Added text

    Note: Due to bugs APERTA-5794, APERTA-5810, APERTA-5808 and APERTA-5849, assertions
    are not implemented in this method
    :return: void function
    """
    title = 'For metadata versioning'
    types = ('Research', 'Research w/Initial Decision Card')
    paper_type = random.choice(types)
    new_prq = {'q1': 'Yes', 'q2': 'Yes', 'q3': [0, 1, 0, 0], 'q4': 'New Data',
               'q5': 'More Data'}
    logging.info('Logging in as {0}'.format(creator_login3['name']))
    dashboard_page = self.cas_login(email=creator_login3['email'], password=login_valid_pw)
    # With a dashboard with several articles, this takes time to load and timeout
    # Big timeout for this step due to large number of papers
    dashboard_page.set_timeout(120)
    dashboard_page.click_create_new_submission_button()
    time.sleep(.5)
    logging.info('Creating Article in {0} of type {1}'.format('PLOS Wombat', paper_type))
    self.create_article(title=title,
                        journal='PLOS Wombat',
                        type_=paper_type,
                        random_bit=True,
                        )
    dashboard_page.restore_timeout()
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # check for flash message
    paper_viewer.validate_ihat_conversions_success()
    paper_id = paper_viewer.get_current_url().split('/')[-1]
    paper_id = paper_id.split('?')[0] if '?' in paper_id else paper_id
    logging.info("Assigned paper id: {0}".format(paper_id))
    paper_viewer.complete_task('Billing')
    paper_viewer.complete_task('Cover Letter')
    paper_viewer.complete_task('Figures')
    paper_viewer.complete_task('Supporting Info')
    paper_viewer.complete_task('Authors')
    paper_viewer.complete_task('Financial Disclosure')
    paper_viewer.complete_task('Additional Information')
    time.sleep(3)
    # refresh !!
    paper_viewer.refresh()
    time.sleep(3)

    # make submission
    paper_viewer.click_submit_btn()
    paper_viewer.confirm_submit_btn()
    paper_viewer.close_submit_overlay()
    # logout
    paper_viewer.logout()

    # If this is an initial decision submission, admin has to invite
    if paper_type == 'Research w/Initial Decision Card':
      logging.info('This is an initial decision paper, logging in as admin to invite.')
      dashboard_page = self.cas_login(email=staff_admin_login['email'], password=login_valid_pw)
      # go to article
      time.sleep(5)
      dashboard_page.go_to_manuscript(paper_id)
      paper_viewer = ManuscriptViewerPage(self.getDriver())
      # click register initial decision on task
      paper_viewer.click_workflow_link()
      workflow_page = WorkflowPage(self.getDriver())
      workflow_page.click_initial_decision_card()
      workflow_page.complete_card('Initial Decision')
      time.sleep(1)
      paper_viewer.logout()

      logging.info('Paper type is initial submission, logging in as creator to complete '
                   'full submission')
      # Log in as a author to make first final submission
      dashboard_page = self.cas_login(email=creator_login3['email'], password=login_valid_pw)
      dashboard_page.go_to_manuscript(paper_id)
      paper_viewer = ManuscriptViewerPage(self.getDriver())
      time.sleep(2)
      # submit article
      paper_viewer.click_submit_btn()
      paper_viewer.confirm_submit_btn()
      paper_viewer.close_submit_overlay()
      # logout
      paper_viewer.logout()

    logging.info('Logging in as the Internal Editor to Register a Decision')
    # Log as editor to approve the manuscript with modifications
    dashboard_page = self.cas_login(email=internal_editor_login['email'], password=login_valid_pw)
    # go to article
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.click_register_decision_card()
    workflow_page.complete_card('Register Decision')
    time.sleep(1)
    workflow_page.logout()

    # Log in as a author to make some changes
    logging.info('Logging in as creator to make changes')
    dashboard_page = self.cas_login(email=creator_login3['email'], password=login_valid_pw)
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.complete_task('Additional Information',
                               click_override=True,
                               data=new_prq)
    # check versioning
    version_btn = paper_viewer._get(paper_viewer._tb_versions_link)
    version_btn.click()
    bar_items = paper_viewer._gets(paper_viewer._bar_items)
    # click on
    bar_items[2].find_elements_by_tag_name('option')[1].click()
    # Following command disabled due to bug APERTA-5849
    # paper_viewer.click_task('prq')
    return self

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
