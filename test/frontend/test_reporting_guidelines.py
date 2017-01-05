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
from Pages.workflow_page import WorkflowPage
from Cards.reporting_guidelines_card import ReportingGuidelinesCard
from Tasks.reporting_guidelines_task import ReportingGuidelinesTask

__author__ = 'achoe@plos.org'


@MultiBrowserFixture
class ReportingGuidelinesTaskTest(CommonTest):
  def test_smoke_reporting_guidelines_styles(self):
    """
    test_reporting_guidelines: Validates the elements, styles of the Reporting Guidelines task and
    card from new document creation through workflow view
    :return: None
    """
    logging.info('Test Reporting Guidelines::styles')
    # User logs in and makes a submission:
    creator_user = random.choice(users)
    logging.info('logging in as user: {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Reporting Guidelines test', journal='PLOS Wombat',
                        type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    short_doi = manuscript_page.get_short_doi()
    # Reporting Guidelines
    manuscript_page.click_task('Reporting Guidelines')
    reporting_guidelines_task = ReportingGuidelinesTask(self.getDriver())
    reporting_guidelines_task.task_ready()
    reporting_guidelines_task.validate_styles()
    reporting_guidelines_task.click_completion_button()
    reporting_guidelines_task.logout()

    # login as a privileged user to validate the presentation of the Reporting Guidelines card.
    staff_user = random.choice(editorial_users)
    logging.info('logging in as user: {0}'.format(staff_user['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to workflow
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('reporting_guidelines')
    reporting_guidelines_card = ReportingGuidelinesCard(self.getDriver())
    reporting_guidelines_card.card_ready()
    reporting_guidelines_card.validate_styles()

  def test_core_reporting_guidelines_upload_prisma(self):
    """
    Validates upload of PRISMA checklist. This applies only to the "Systematic Reviews" and "Meta-analyses" options
    on this task. Also validates style of the file upload widget, since this wasn't covered in style validation due
    to lack of entry.
    :return: None
    """
    logging.info('Test Reporting Guidelines::upload_prisma')
    current_path = os.getcwd()
    logging.info(current_path)
    # User logs in and submits a manuscript
    creator_user = random.choice(users)
    logging.info('logging in as user: {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Reporting Guidelines test', journal='PLOS Wombat',
                    type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    short_doi = manuscript_page.get_short_doi()
    # Reporting Guidelines
    manuscript_page.click_task('Reporting Guidelines')
    reporting_guidelines_task = ReportingGuidelinesTask(self.getDriver())
    reporting_guidelines_task.task_ready()
    selected = reporting_guidelines_task.make_selections()
    file_ = reporting_guidelines_task.upload_prisma_review_checklist()
    reporting_guidelines_task.click_completion_button()
    reporting_guidelines_task.logout()

    # login as a privileged user to validate the presentation of the Reporting Guidelines card.
    staff_user = random.choice(editorial_users)
    logging.info('logging in as user: {0}'.format(staff_user['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    dashboard_page.page_ready()
    dashboard_page.go_to_manuscript(short_doi)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # go to workflow
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_card('reporting_guidelines')
    reporting_guidelines_card = ReportingGuidelinesCard(self.getDriver())
    reporting_guidelines_card.card_ready()
    reporting_guidelines_card.check_selections(choices=selected, filename=file_)

  def test_core_reporting_guidelines_download_uploaded_prisma(self):
    """
    Validates download of a PRISMA checklist that has been uploaded
    :return: None
    """
    logging.info('Test Reporting Guidelines::download_prisma')
    current_path = os.getcwd()
    logging.info(current_path)
    # User logs in and submits a manuscript
    creator_user = random.choice(users)
    logging.info('logging in as user: {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Reporting Guidelines test', journal='PLOS Wombat',
                    type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    # Reporting Guidelines
    manuscript_page.click_task('Reporting Guidelines')
    reporting_guidelines_task = ReportingGuidelinesTask(self.getDriver())
    reporting_guidelines_task.task_ready()
    reporting_guidelines_task.make_selections(prisma=True)
    reporting_guidelines_task.upload_prisma_review_checklist()
    reporting_guidelines_task.download_prisma_checklist()
    reporting_guidelines_task.click_completion_button()

  def test_core_reporting_guidelines_replace_uploaded_prisma(self):
    """
    Validates replacement of a PRISMA checklist that has been uploaded
    :return: None
    """
    logging.info('Test Reporting Guidelines::replace_prisma')
    current_path = os.getcwd()
    logging.info(current_path)
    # User logs in and submits a manuscript
    creator_user = random.choice(users)
    logging.info('logging in as user: {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Reporting Guidelines test', journal='PLOS Wombat',
                    type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    # Reporting Guidelines
    manuscript_page.click_task('Reporting Guidelines')
    reporting_guidelines_task = ReportingGuidelinesTask(self.getDriver())
    reporting_guidelines_task.task_ready()
    reporting_guidelines_task.make_selections()
    reporting_guidelines_task.upload_prisma_review_checklist()
    reporting_guidelines_task.replace_prisma_checklist()
    reporting_guidelines_task.click_completion_button()

  def test_core_reporting_guidelines_delete_uploaded_prisma(self):
    """
    Validates deletion of a PRISMA checklist that has been uploaded
    :return: None
    """
    logging.info('Test Reporting Guidelines::delete_prisma')
    current_path = os.getcwd()
    logging.info(current_path)
    # User logs in and submits a manuscript
    creator_user = random.choice(users)
    logging.info('logging in as user: {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Reporting Guidelines test', journal='PLOS Wombat',
                    type_='generateCompleteApexData', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    # Reporting Guidelines
    manuscript_page.click_task('Reporting Guidelines')
    reporting_guidelines_task = ReportingGuidelinesTask(self.getDriver())
    reporting_guidelines_task.task_ready()
    reporting_guidelines_task.make_selections()
    reporting_guidelines_task.upload_prisma_review_checklist()
    # Adding sleep here, as the delete is attempted before the upload completes
    time.sleep(1)
    reporting_guidelines_task.delete_prisma_checklist()
    reporting_guidelines_task.click_completion_button()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
