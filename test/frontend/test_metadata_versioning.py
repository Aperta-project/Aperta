#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This test case validates metadata versioning for Aperta.
"""

import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from frontend.common_test import CommonTest
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.workflow_page import WorkflowPage
from Base.Resources import creator_login1, staff_admin_login, internal_editor_login
from frontend.Tasks.additional_information_task import AITask

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

    :return: void function
    """
    logging.info('Test Metadata Versioning')
    title = 'For metadata versioning'
    types = ('Research', 'Research w/Initial Decision Card')
    paper_type = random.choice(types)
    first_prq = {'q1': 'No', 'q2': 'No', 'q3': [0, 0, 0, 1], 'q4': 'First Collection',
                 'q5': 'First Short Title'}
    new_prq = {'q1': 'Yes', 'q1_child_answer':'Results and data',
               'q1_child_file':('frontend/assets/imgs/fur_elise_nocompress.tiff', 'Dog'),
               'q2': 'Yes',
               'q2_child1_answer': 'Test_title',
               'q2_child2_answer': 'Test Author Name',
               'q2_child3_answer': 'Test Journal',
               'q2_child4_answer': '1',
               'q3': [0, 1, 0, 0],
               'q3_child_answer': ['','n/a', ''],
               'q4': 'New Collection',
               'q5': 'More Short Title'}
    creator_user = creator_login1['name']
    logging.info('Logging in as {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_login1['email'])
    # With a dashboard with several articles, this takes time to load and timeout
    # Big timeout for this step due to large number of papers
    dashboard_page._wait_on_lambda(lambda: len(dashboard_page._gets(dashboard_page._dashboard_invite_title)) >= 1)
    dashboard_page.click_create_new_submission_button()
    time.sleep(.5)
    self.create_article(title=title, journal='PLOS Wombat', type_=paper_type, random_bit=True)
    dashboard_page.restore_timeout()
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    short_doi = manuscript_page.get_current_url().split('/')[-1]
    short_doi = short_doi.split('?')[0] if '?' in short_doi else short_doi
    logging.info("Assigned paper short doi: {0}".format(short_doi))
    #complete tasks to submit manuscript
    manuscript_page.complete_task('Billing')
    manuscript_page.complete_task('Authors', author=creator_login1)
    manuscript_page.complete_task('Cover Letter')
    manuscript_page.complete_task('Figures')
    manuscript_page.complete_task('Supporting Info')
    manuscript_page.complete_task('Financial Disclosure')
    manuscript_page.complete_task('Additional Information', click_override=False,
                               data=first_prq)
    manuscript_page.complete_task('Early Article Posting')
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.complete_task('Title And Abstract')
    time.sleep(3)
    # make submission
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_submit_overlay()
    # logout
    manuscript_page.logout()

    # If this is an initial decision submission, admin has to invite
    if paper_type == 'Research w/Initial Decision Card':
      logging.info('This is an initial decision paper, logging in as admin to invite.')
      dashboard_page = self.cas_login(email=staff_admin_login['email'])
      # go to article
      time.sleep(5)
      dashboard_page.go_to_manuscript(short_doi)
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
      dashboard_page = self.cas_login(email=creator_login1['email'])
      dashboard_page.go_to_manuscript(short_doi)
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
    dashboard_page = self.cas_login(email=internal_editor_login['email'])
    # go to article
    dashboard_page.go_to_manuscript(short_doi)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.click_register_decision_card()
    workflow_page.complete_card('Register Decision')
    workflow_page.logout()

    # Log in as a author to make some changes in "Additional Information" task
    logging.info('Logging in as creator to make changes')
    dashboard_page = self.cas_login(email=creator_login1['email'])
    dashboard_page._wait_on_lambda(lambda: len(dashboard_page._gets(dashboard_page._dashboard_invite_title)) >= 1)
    dashboard_page.go_to_manuscript(short_doi)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    paper_viewer.click_task('Additional Information')
    paper_viewer.complete_task('Additional Information',
                               click_override=True,
                               data=new_prq)
    paper_viewer.select_manuscript_version_item('compare',1)
    time.sleep(1)
    paper_diff = ManuscriptViewerPage(self.getDriver())
    paper_diff.click_task('Additional Information')

    # assert Diff Icons
    diff_icons = paper_diff._gets(paper_diff._paper_sidebar_diff_icons)
    assert diff_icons

    # assertion for removed and added text
    paper_viewer_diff = ManuscriptViewerPage(self.getDriver())
    paper_viewer_diff.click_task('Additional Information')
    # Version differences
    ai_diff = AITask(self._driver)
    removed_answer1 = ai_diff._gets(ai_diff._diff_removed)[0]
    assert 'No' in removed_answer1.text

    added_answer1 = ai_diff._gets(ai_diff._diff_added)[0]
    assert 'Yes' in added_answer1.text
    # check added file name
    added_file_name = ai_diff._gets(ai_diff._diff_added)[2]
    file_sent = new_prq['q1_child_file'][0]
    expected_file_name = file_sent.split('/')[-1]
    assert expected_file_name in added_file_name.text, \
        'Expected file name: \'{0}\' does not match file name in version view: \'{1}\''\
        .format(expected_file_name, added_file_name.text)

    return self

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
