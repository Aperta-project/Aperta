#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test validates the Send to Apex workflow
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from frontend.common_test import CommonTest
from Base.Resources import staff_admin_login, users, editorial_users
from Pages.workflow_page import WorkflowPage
from Pages.manuscript_viewer import ManuscriptViewerPage
from Tasks.upload_manuscript_task import UploadManuscriptTask
from frontend.Cards.send_to_apex_card import SendToApexCard
from Cards.register_decision_card import RegisterDecisionCard
from Base.PostgreSQL import PgSQL

__author__ = 'scadavid@plos.org'

@MultiBrowserFixture
class SendToApexTest(CommonTest):
  """
  Validate the elements of the Send to Apex Card
  Validate if the data in the frontend match the data in the backend sent to Apex
  """

  def test_send_to_apex_message(self):
    """
    test_send_to_apex_message: Validate if the Send to Apex card displays the corresponding messages
    """
    logging.info('test_send_to_apex_message')
    # Create base data - new papers
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='NoCards')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    # Request title to make sure the required page is loaded
    short_doi = manuscript_page.get_paper_short_doi_from_url()
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
    # Disable Upload Manuscript Task
    data = manuscript_page.complete_task('Upload Manuscript', click_override=True)
    # go to workflow and open Send to Apex Card
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    card_title = 'Send to Apex'
    workflow_page.click_card('send_to_apex', card_title)
    send_to_apex_card = SendToApexCard(self.getDriver())
    send_to_apex_card.click_send_to_apex_button()
    send_to_apex_card.click_close_apex()
    # Open Register Decision Card
    time.sleep(3)
    workflow_page.click_card('register_decision')
    register_decision = RegisterDecisionCard(self.getDriver())
    register_decision.register_decision('Accept')
    # Time needed to proceed after closing the RegisterDecisionCard
    time.sleep(3)
    card_title = 'Send to Apex'
    workflow_page.click_card('send_to_apex', card_title)
    send_to_apex_card = SendToApexCard(self.getDriver())
    send_to_apex_card.click_send_to_apex_button()
    send_to_apex_card.validate_send_to_apex_message()

  # Disabled for APERTA-8500
  def _test_send_to_apex_card_style(self):
    """
    test_send_to_apex_card_style: Validate the styles of Send to Apex Card
    """
    logging.info('test_send_to_apex_card_style')
    # Create base data - new papers
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='NoCards')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    # Request title to make sure the required page is loaded
    short_doi = manuscript_page.get_paper_short_doi_from_url()
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
    # Disable Upload Manuscript Task
    data = manuscript_page.complete_task('Upload Manuscript', click_override=True)
    # go to workflow and open Send to Apex Card
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    card_title = 'Send to Apex'
    workflow_page.click_card('send_to_apex', card_title)
    send_to_apex_card = SendToApexCard(self.getDriver())
    send_to_apex_card.click_send_to_apex_button()
    send_to_apex_card.click_close_apex()
    # Open Register Decision Card
    time.sleep(3)
    workflow_page.click_card('register_decision')
    register_decision = RegisterDecisionCard(self.getDriver())
    register_decision.register_decision('Accept')
    # Time needed to proceed after closing the RegisterDecisionCard
    time.sleep(3)
    card_title = 'Send to Apex'
    workflow_page.click_card('send_to_apex', card_title)
    send_to_apex_card = SendToApexCard(self.getDriver())
    send_to_apex_card.click_send_to_apex_button()
    send_to_apex_card.validate_card_elements(short_doi)

  def test_send_to_apex_file(self):
    """
    test_send_to_apex_file: Validate if the file sent to apex contains the correct information
    """
    logging.info('test_send_to_apex_file')
    # Create base data - new papers
    creator_user = users[0]
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='generateCompleteApexData')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    # Request title to make sure the required page is loaded
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    db_title, db_abstract = PgSQL().query('SELECT title, abstract '
                                          'FROM papers '
                                          'WHERE short_doi=%s;', (short_doi,))[0]
    db_title = unicode(db_title, encoding='utf-8', errors='strict')
    db_abstract = unicode(db_abstract, encoding='utf-8', errors='strict')
    manuscript_page.complete_task('Additional Information')
    manuscript_page.complete_task('Authors', author=creator_user)
    manuscript_page.complete_task('Billing')
    manuscript_page.complete_task('Competing Interest')
    manuscript_page.complete_task('Cover Letter')
    manuscript_page.complete_task('Data Availability')
    manuscript_page.complete_task('Early Article Posting')
    manuscript_page.complete_task('Ethics Statement')
    manuscript_page.complete_task('Figures')
    manuscript_page.complete_task('Financial Disclosure')
    manuscript_page.complete_task('New Taxon')
    manuscript_page.complete_task('Reporting Guidelines')
    manuscript_page.complete_task('Reviewer Candidates')
    manuscript_page.complete_task('Supporting Info')
    manuscript_page.complete_task('Upload Manuscript')
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
    # go to workflow and open Send to Apex Card
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('register_decision')
    register_decision = RegisterDecisionCard(self.getDriver())
    register_decision.register_decision('Accept')
    # Time needed to proceed after closing the RegisterDecisionCard
    time.sleep(3)
    card_title = 'Send to Apex'
    workflow_page.click_card('send_to_apex', card_title)
    send_to_apex_card = SendToApexCard(self.getDriver())
    send_to_apex_card.click_send_to_apex_button()
    # Connecting to FTP
    logging.info('Connecting to FTP and taking the file')
    filename, directory_path = send_to_apex_card.connect_to_aperta_ftp(short_doi)
    json_data = send_to_apex_card.extract_zip_file_and_load_json(filename, directory_path)
    send_to_apex_card.validate_json_information(json_data, short_doi, db_title, db_abstract)

if __name__ == '__main__':
  CommonTest._run_tests_randomly()