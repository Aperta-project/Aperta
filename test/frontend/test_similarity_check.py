#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This test case validates style and function of Similarity Check
"""
from datetime import datetime
import logging
import os
import random

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import users, editorial_users, super_admin_login, handling_editor_login, cover_editor_login
from frontend.common_test import CommonTest
from frontend.Cards.assign_team_card import AssignTeamCard
from frontend.Cards.similarity_check_card import SimilarityCheckCard
from .Pages.admin_workflows import AdminWorkflowsPage
from frontend.Pages.card_settings import CardSettings
from frontend.Pages.manuscript_viewer import ManuscriptViewerPage
from frontend.Pages.workflow_page import WorkflowPage
from .Pages.sim_check_settings import SimCheckSettings

__author__ = 'gtimonina@plos.org'


@MultiBrowserFixture
class SimilarityCheckTest(CommonTest):
  """
  Validate the elements, styles, functions of the Similarity Check card
  """

  def rest_core_settings_validate_components_styles(self):
    """
    test_admin: Validate elements and styles for the base Similarity Check page
    :return: void function
    """
    logging.info('Validating Similarity Check Settings: page components and styles')
    user_type = super_admin_login
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.page_ready()
    dashboard_page.click_admin_link()
    adm_wf_page = AdminWorkflowsPage(self.getDriver())
    adm_wf_page.page_ready()
    adm_wf_page.open_mmt('Similarity Check test')
    # adm_wf_page.click_on_card_settings(adm_wf_page._sim_check_card_settings)
    adm_wf_page.click_on_card_settings(adm_wf_page._similarity_check_card)

    card_settings = SimCheckSettings(self.getDriver())
    card_settings.overlay_ready()
    card_settings.validate_card_setting_style('Similarity Check: Settings')
    card_settings.validate_setting_style_and_components()

    card_settings.click_cancel()

  def test_smoke_generate_manually_and_validate_access(self):
    """
    test_smoke_generate_manually_and_validate_access:
    Validates the similarity check card presence in a workflow view, generating report manually,
    validates access while the report is generating as it may take several minutes.
    Validates form elements and styles.
    Testing default settings, automation is Off.
    :return: void function
    """
    #
    # the card appears only in Workflow view
    current_path = os.getcwd()
    logging.info(current_path)

    logging.info('Test Similarity Check with Automation Off::smoke generate report manually and validate access')

    # auto_report_options = ['off', 'at_first_full_submission', 'after_major_revise_decision',
    #                        'after_minor_revise_decision', 'after_any_first_revise_decision']
    # auto_settings = random.choice(auto_report_options)

    # self._set_automation_ui('Similarity Check test', auto_option=auto_settings)

    # log as an author and create new submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.click_create_new_submission_button()
    title = 'Similarity Check test with default settings - generate report'
    self.create_article(title=title, journal='PLOS Wombat', type_='Similarity Check test',
                        random_bit=True, format_='word')
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    logging.info("Assigned paper short doi: {0}".format(short_doi))
    # Complete cards
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.complete_task('Title And Abstract')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_submit_overlay()
    # logout
    manuscript_page.logout()

    #log as editorial user
    staff_user = random.choice(editorial_users)
    # TODO: check cover_editor_login, handling_editor_login
    logging.info('Logging in as user: {0}'.format(staff_user['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True

    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.page_ready()
    # AC#2 - check the card appears only in workflow view, not in manuscript view
    assert not paper_viewer.is_task_present("Similarity Check"), "Similarity Check card should not be " \
                                                                 "available in Manuscript view"
    # go to Workflow view
    paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()

    auto_setting_default = 'off'
    # get auto settings from db, it is expected to be off by default
    auto_settings_db = workflow_page.get_sim_check_auto_settings(short_doi = short_doi, from_admin_mmt = False)
    assert auto_settings_db == 'off', 'Automation setting in db: \'{0}\' is not ' \
                                      'the expected: \'{1}\''.format(auto_settings_db, auto_setting_default)

    workflow_page.click_card('similarity_check')
    sim_check = SimilarityCheckCard(self.getDriver())
    sim_check.card_ready()
    # sim_check._wait_for_element(sim_check._get(sim_check._decision_labels))
    sim_check.validate_card_header(short_doi)
    sim_check.validate_styles_and_components(auto_setting_default) # generating report is triggered by submission manuscript
    # if not auto_settings == 'at_first_full_submission':
    #   sim_check.generate_manual_report()

    task_url, start_time = sim_check.generate_manual_report()
    sim_check.logout()

    # Similarity checks may take up to several minutes to complete,
    # so we'll use this time to run  access validation test
    logging.info("Switching to Access validation test at: {0}".format(start_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ')))
    self.validate_access(staff_user)

    finish_time = datetime.now()
    diff_time = finish_time - start_time

    seconds = diff_time.seconds
    logging.info("Access validation test finished at: {0}".format(finish_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ')))

    logging.info('Elapsed time in seconds: {0}'.format(str(seconds)))

    #
    # log as staff_user
    logging.info('Logging in as user: {0} to validate similarity check report'.format(staff_user['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    dashboard_page.page_ready()
    self._driver.get(task_url)   #go_to_manuscript(short_doi)
    # self._driver.navigated = True

    # paper_viewer = ManuscriptViewerPage(self.getDriver())
    # paper_viewer.page_ready()
    sim_check = SimilarityCheckCard(self.getDriver())
    sim_check.card_ready()
    sim_check.validate_report_result()
  #

  def validate_access(self, staff_user_to_skip):
    """
    validate_access: Validates access of internal and external
    editorial users to the Similarity Check card
    :return: void function
    """
    logging.info('Test Similarity Check::validate_access, default settings')

    # log as author and create new submission using 'Similarity Check test' mmt
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    # dashboard_page.page_ready()
    dashboard_page._wait_on_lambda(lambda: len(dashboard_page._gets(dashboard_page._dashboard_invite_title)) >= 1)
    dashboard_page.click_create_new_submission_button()
    self.create_article(title='Similarity Check test with default settings - validate access',
                        journal='PLOS Wombat', type_='Similarity Check test', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    short_doi = manuscript_page.get_paper_short_doi_from_url()
    logging.info("Assigned paper short doi: {0}".format(short_doi))
    # Complete cards
    manuscript_page.complete_task('Upload Manuscript')
    manuscript_page.complete_task('Title And Abstract')
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_submit_overlay()
    # logout
    manuscript_page.logout()


    # log as internal editorial users
    # editorial_users = [super_admin_login]


    handler_and_cover_assigned = False

    for staff_user in editorial_users:
      # skip staff user who was chosen and checked in the previous test
      if staff_user == staff_user_to_skip:
        continue
      logging.info('Logging in as user: {0}'.format(staff_user['name']))
      dashboard_page = self.cas_login(email=staff_user['email'])
      dashboard_page.page_ready()
      dashboard_page.go_to_manuscript(short_doi)
      self._driver.navigated = True
      paper_viewer = ManuscriptViewerPage(self.getDriver())
      # go to Workflow view
      paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
      paper_viewer.click_workflow_link()
      workflow_page = WorkflowPage(self.getDriver())
      workflow_page.page_ready()

      workflow_page.click_card('similarity_check')
      sim_check = SimilarityCheckCard(self.getDriver())
      sim_check.card_ready()

      # sim_check.validate_card_header(short_doi)
      card_title = sim_check._get(sim_check._card_heading)
      assert card_title.text == 'Similarity Check'
      sim_check.validate_generate_report_button()

      # check the card is editable
      completed_section_button = sim_check._get(sim_check._btn_done)
      assert completed_section_button.text in ["MAKE CHANGES TO THIS TASK",
                                               "I AM DONE WITH THIS TASK"], completed_section_button.text

      # assign cover editor and handling editor to test their access to the card
      if not handler_and_cover_assigned: # just to be sure we do it once
        sim_check.click_close_button_bottom()
        workflow_page._wait_on_lambda(lambda: workflow_page.get_current_url().split('/')[-1] == 'workflow')
        workflow_page.click_card('assign_team')
        assign_team = AssignTeamCard(self.getDriver())
        assign_team.card_ready()
        assign_team.assign_role(cover_editor_login, 'Cover Editor')
        assign_team.assign_role(handling_editor_login, 'Handling Editor')
        handler_and_cover_assigned = True
      # logout
      sim_check.logout()

    # log as cover/handling editor
    # if manuscript is submitted, the card is read-only
    # so it should not be editable (confirmed by Shane)
    external_editors = [cover_editor_login, handling_editor_login]
    for staff_user in external_editors:
      logging.info('Logging in as user: {0}'.format(staff_user['name']))
      dashboard_page = self.cas_login(email=staff_user['email'])
      dashboard_page.page_ready()
      dashboard_page.go_to_manuscript(short_doi)
      self._driver.navigated = True
      paper_viewer = ManuscriptViewerPage(self.getDriver())
      # go to Workflow view
      paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
      paper_viewer.click_workflow_link()
      workflow_page = WorkflowPage(self.getDriver())
      workflow_page.page_ready()
      workflow_page.click_card('similarity_check')
      sim_check = SimilarityCheckCard(self.getDriver())
      sim_check._wait_for_element(sim_check._get(sim_check._card_heading))
      card_title = sim_check._get(sim_check._card_heading)
      assert card_title.text == 'Similarity Check'
      assert sim_check._check_for_absence_of_element(sim_check._btn_done)

      # logout
      sim_check.logout()



  # def validate_access(self):
  #   """
  #   validate_access: Validates access of internal and external
  #   editorial users to the Similarity Check card
  #   :return: void function
  #   """
  #   logging.info('Test Similarity Check::core_validate_access')
  #   # log as author and create new submission using 'Similarity Check test' mmt
  #   creator_user = random.choice(users)
  #   dashboard_page = self.cas_login(email=creator_user['email'])
  #   # dashboard_page.page_ready()
  #   dashboard_page._wait_on_lambda(lambda: len(dashboard_page._gets(dashboard_page._dashboard_invite_title)) >= 1)
  #   dashboard_page.click_create_new_submission_button()
  #   title = 'For Similarity Check test'
  #   self.create_article(title=title, journal='PLOS Wombat', type_='Similarity Check test', random_bit=True)
  #   manuscript_page = ManuscriptViewerPage(self.getDriver())
  #   manuscript_page.page_ready()
  #   short_doi = manuscript_page.get_paper_short_doi_from_url()
  #   logging.info("Assigned paper short doi: {0}".format(short_doi))
  #   # Complete cards
  #   manuscript_page.complete_task('Upload Manuscript')
  #   manuscript_page.complete_task('Title And Abstract')
  #   manuscript_page.click_submit_btn()
  #   manuscript_page.confirm_submit_btn()
  #   manuscript_page.close_submit_overlay()
  #   # logout
  #   manuscript_page.logout()
  #
  #   # log as internal editorial users
  #   # editorial_users = [super_admin_login]
  #   for staff_user in editorial_users:
  #     logging.info('Logging in as user: {0}'.format(staff_user['name']))
  #     dashboard_page = self.cas_login(email=staff_user['email'])
  #     # dashboard_page.page_ready()
  #     dashboard_page._wait_on_lambda(lambda: len(dashboard_page._gets(dashboard_page._dashboard_invite_title)) >= 1)
  #     dashboard_page.go_to_manuscript(short_doi)
  #     self._driver.navigated = True
  #     paper_viewer = ManuscriptViewerPage(self.getDriver())
  #     # go to Workflow view
  #     paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
  #     paper_viewer.click_workflow_link()
  #     workflow_page = WorkflowPage(self.getDriver())
  #     workflow_page.page_ready()
  #
  #     workflow_page.click_card('similarity_check')
  #     sim_check = SimilarityCheckCard(self.getDriver())
  #     sim_check.card_ready()
  #
  #     # sim_check.validate_card_header(short_doi)
  #     card_title = sim_check._get(sim_check._card_heading)
  #     assert card_title.text == 'Similarity Check'
  #     sim_check.validate_generate_report_button()
  #
  #     # check the card is editable
  #     completed_section_button = sim_check._get(sim_check._btn_done)
  #     assert completed_section_button.text in ["MAKE CHANGES TO THIS TASK",
  #                                              "I AM DONE WITH THIS TASK"], completed_section_button.text
  #
  #     # # assign cover editor and handling editor to test their access to the card
  #     # if staff_user == super_admin_login: # just to be sure we do it once
  #     #   sim_check.click_close_button_bottom()
  #     #   workflow_page._wait_on_lambda(lambda: workflow_page.get_current_url().split('/')[-1] == 'workflow')
  #     #   workflow_page.click_card('assign_team')
  #     #   assign_team = AssignTeamCard(self.getDriver())
  #     #   assign_team.card_ready()
  #     #   assign_team.assign_role(cover_editor_login, 'Cover Editor')
  #     #   assign_team.assign_role(handling_editor_login, 'Handling Editor')
  #     # logout
  #     sim_check.logout()
  #
  #   # log as cover/handling editor
  #   # if manuscript is submitted, the card is read-only
  #   # so it should not be editable (confirmed by Shane)
  #   external_editors = [cover_editor_login, handling_editor_login]
  #   for staff_user in external_editors:
  #     logging.info('Logging in as user: {0}'.format(staff_user['name']))
  #     dashboard_page = self.cas_login(email=staff_user['email'])
  #     # dashboard_page.page_ready()
  #     dashboard_page._wait_on_lambda(lambda: len(dashboard_page._gets(dashboard_page._dashboard_invite_title)) >= 1)
  #     dashboard_page.go_to_manuscript(short_doi)
  #     self._driver.navigated = True
  #     paper_viewer = ManuscriptViewerPage(self.getDriver())
  #     # go to Workflow view
  #     paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
  #     paper_viewer.click_workflow_link()
  #     workflow_page = WorkflowPage(self.getDriver())
  #     workflow_page.page_ready()
  #     workflow_page.click_card('similarity_check')
  #     sim_check = SimilarityCheckCard(self.getDriver())
  #     sim_check._wait_for_element(sim_check._get(sim_check._card_heading))
  #     card_title = sim_check._get(sim_check._card_heading)
  #     assert card_title.text == 'Similarity Check'
  #     assert sim_check._check_for_absence_of_element(sim_check._btn_done)
  #
  #     # logout
  #     sim_check.logout()



  #
  # def rest_smoke_sim_check_default(self):
  #   """
  #   test_core_sim_check_default: Validates the similarity check card presence,
  #   form elements and styles.
  #   :return: void function
  #   """
  #   #
  #   # the card appears only in Workflow view
  #   current_path = os.getcwd()
  #   logging.info(current_path)
  #
  #   # log as an author and create new submission
  #   creator_user = random.choice(users)
  #   dashboard_page = self.cas_login(email=creator_user['email'])
  #   dashboard_page.click_create_new_submission_button()
  #   title = 'For Similarity Check test'
  #   self.create_article(title=title, journal='PLOS Wombat', type_='Similarity Check test',
  #                       random_bit=True, format_='word')
  #   manuscript_page = ManuscriptViewerPage(self.getDriver())
  #   manuscript_page.page_ready()
  #   short_doi = manuscript_page.get_paper_short_doi_from_url()
  #   logging.info("Assigned paper short doi: {0}".format(short_doi))
  #   # Complete cards
  #   manuscript_page.complete_task('Upload Manuscript')
  #   manuscript_page.complete_task('Title And Abstract')
  #   manuscript_page.click_submit_btn()
  #   manuscript_page.confirm_submit_btn()
  #   manuscript_page.close_submit_overlay()
  #   # logout
  #   manuscript_page.logout()
  #
  #   #log as editorial user
  #   staff_user = random.choice(editorial_users)
  #   logging.info('Logging in as user: {0}'.format(staff_user['name']))
  #   dashboard_page = self.cas_login(email=staff_user['email'])
  #   dashboard_page.go_to_manuscript(short_doi)
  #   self._driver.navigated = True
  #   paper_viewer = ManuscriptViewerPage(self.getDriver())
  #   # AC#2 - check the card appears only in workflow view
  #   assert not paper_viewer.is_task_present("Similarity Check"), "Similarity Check card should not be " \
  #                                                                "available in Manuscript view"
  #   # go to Workflow view
  #   paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
  #   paper_viewer.click_workflow_link()
  #   workflow_page = WorkflowPage(self.getDriver())
  #   workflow_page.page_ready()
  #
  #   # get auto settings from db
  #   auto_settings = workflow_page.get_sim_check_auto_settings(short_doi = short_doi, from_admin_mmt = False)
  #
  #   workflow_page.click_card('similarity_check')
  #   sim_check = SimilarityCheckCard(self.getDriver())
  #   sim_check.card_ready()
  #   #sim_check._wait_for_element(sim_check._get(sim_check._decision_labels))
  #   sim_check.validate_card_header(short_doi)
  #   sim_check.validate_styles_and_components(auto_settings) # generating report is triggered by submission manuscript
  #   if not auto_settings == 'at_first_full_submission':
  #     sim_check.generate_manual_report()
  #
  #   sim_check.validate_report_result()
  #
  # # def test_core_validate_access(self):
  #   """
  #   test_core_validate_access: Validates access of internal and external
  #   editorial users to the Similarity Check card
  #   :return: void function
  #   """
  #   logging.info('Test Similarity Check::core_validate_access')
  #   # log as author and create new submission using 'Similarity Check test' mmt
  #   creator_user = random.choice(users)
  #   dashboard_page = self.cas_login(email=creator_user['email'])
  #   # dashboard_page.page_ready()
  #   dashboard_page._wait_on_lambda(lambda: len(dashboard_page._gets(dashboard_page._dashboard_invite_title)) >= 1)
  #   dashboard_page.click_create_new_submission_button()
  #   title = 'For Similarity Check test'
  #   self.create_article(title=title, journal='PLOS Wombat', type_='Similarity Check test', random_bit=True)
  #   manuscript_page = ManuscriptViewerPage(self.getDriver())
  #   manuscript_page.page_ready()
  #   short_doi = manuscript_page.get_paper_short_doi_from_url()
  #   logging.info("Assigned paper short doi: {0}".format(short_doi))
  #   # Complete cards
  #   manuscript_page.complete_task('Upload Manuscript')
  #   manuscript_page.complete_task('Title And Abstract')
  #   manuscript_page.click_submit_btn()
  #   manuscript_page.confirm_submit_btn()
  #   manuscript_page.close_submit_overlay()
  #   # logout
  #   manuscript_page.logout()
  #
  #   # log as internal editorial users
  #   # editorial_users = [super_admin_login]
  #   for staff_user in editorial_users:
  #     logging.info('Logging in as user: {0}'.format(staff_user['name']))
  #     dashboard_page = self.cas_login(email=staff_user['email'])
  #     # dashboard_page.page_ready()
  #     dashboard_page._wait_on_lambda(lambda: len(dashboard_page._gets(dashboard_page._dashboard_invite_title)) >= 1)
  #     dashboard_page.go_to_manuscript(short_doi)
  #     self._driver.navigated = True
  #     paper_viewer = ManuscriptViewerPage(self.getDriver())
  #     # go to Workflow view
  #     paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
  #     paper_viewer.click_workflow_link()
  #     workflow_page = WorkflowPage(self.getDriver())
  #     workflow_page.page_ready()
  #
  #     workflow_page.click_card('similarity_check')
  #     sim_check = SimilarityCheckCard(self.getDriver())
  #     sim_check.card_ready()
  #
  #     # sim_check.validate_card_header(short_doi)
  #     card_title = sim_check._get(sim_check._card_heading)
  #     assert card_title.text == 'Similarity Check'
  #     sim_check.validate_generate_report_button()
  #
  #     # check the card is editable
  #     completed_section_button = sim_check._get(sim_check._btn_done)
  #     assert completed_section_button.text in ["MAKE CHANGES TO THIS TASK",
  #                                              "I AM DONE WITH THIS TASK"], completed_section_button.text
  #
  #     # # assign cover editor and handling editor to test their access to the card
  #     # if staff_user == super_admin_login: # just to be sure we do it once
  #     #   sim_check.click_close_button_bottom()
  #     #   workflow_page._wait_on_lambda(lambda: workflow_page.get_current_url().split('/')[-1] == 'workflow')
  #     #   workflow_page.click_card('assign_team')
  #     #   assign_team = AssignTeamCard(self.getDriver())
  #     #   assign_team.card_ready()
  #     #   assign_team.assign_role(cover_editor_login, 'Cover Editor')
  #     #   assign_team.assign_role(handling_editor_login, 'Handling Editor')
  #     # logout
  #     sim_check.logout()
  #
  #   # log as cover/handling editor
  #   # if manuscript is submitted, the card is read-only
  #   # so it should not be editable (confirmed by Shane)
  #   external_editors = [cover_editor_login, handling_editor_login]
  #   for staff_user in external_editors:
  #     logging.info('Logging in as user: {0}'.format(staff_user['name']))
  #     dashboard_page = self.cas_login(email=staff_user['email'])
  #     # dashboard_page.page_ready()
  #     dashboard_page._wait_on_lambda(lambda: len(dashboard_page._gets(dashboard_page._dashboard_invite_title)) >= 1)
  #     dashboard_page.go_to_manuscript(short_doi)
  #     self._driver.navigated = True
  #     paper_viewer = ManuscriptViewerPage(self.getDriver())
  #     # go to Workflow view
  #     paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
  #     paper_viewer.click_workflow_link()
  #     workflow_page = WorkflowPage(self.getDriver())
  #     workflow_page.page_ready()
  #     workflow_page.click_card('similarity_check')
  #     sim_check = SimilarityCheckCard(self.getDriver())
  #     sim_check._wait_for_element(sim_check._get(sim_check._card_heading))
  #     card_title = sim_check._get(sim_check._card_heading)
  #     assert card_title.text == 'Similarity Check
  #     assert sim_check._check_for_absence_of_element(sim_check._btn_done)
  #
  #     # logout
  #     sim_check.logout()


  # def _set_automation_ui(self, mmt_name, auto_option='off'):
  #   """
  #   Set Similarity Check automation options for specific manuscript template using db
  #   :param: mmt_name: manuscript template name
  #   :param: auto_option: string: one of the options: 'off','at_first_full_submission',
  #   'after_major_revise_decision','after_minor_revise_decision','after_any_first_revise_decision'
  #   :return: void function
  #   """
  #   # logging.info('Validating Similarity Check page components and styles')
  #   # user_type = super_admin_login
  #   # # add staff admin & Journal Setup Admin
  #   # logging.info('Logging in as user: {0}'.format(user_type))
  #   # dashboard_page = self.cas_login(email=user_type['email'])
  #   # dashboard_page.page_ready()
  #   # #dashboard_page._wait_on_lambda(lambda: len(dashboard_page._gets(dashboard_page._dashboard_invite_title)) >= 1)
  #   # dashboard_page.click_admin_link()
  #   # adm_wf_page = SimCheckSettings(self.getDriver())
  #   # adm_wf_page.overlay_ready()
  #   # adm_wf_page.open_mmt(mmt_name)
  #   #
  #   # adm_wf_page.click_on_card_settings(adm_wf_page._sim_check_card_settings)
  #   #
  #   # if auto_option == 'off':
  #   #   adm_wf_page.set_automation(automation=False)
  #   # else:
  #   #   adm_wf_page.set_automation(automation=True)
  #   #   if auto_option == 'at_first_full_submission':
  #   #     adm_wf_page.set_after_submission_option(0)  # after first submission
  #   #   else:
  #   #     adm_wf_page.set_after_submission_option(1)  # after revision
  #   #     if auto_option == 'after_major_revise_decision':
  #   #       adm_wf_page.select_and_validate_after_revision_option('major revision')
  #   #     elif auto_option == 'after_minor_revise_decision':
  #   #       adm_wf_page.select_and_validate_after_revision_option('minor revision')
  #   #     elif auto_option == 'after_any_first_revise_decision':
  #   #       adm_wf_page.select_and_validate_after_revision_option('any first revision')
  #   #
  #   # adm_wf_page.click_save_settings()
  #   # adm_wf_page.logout()

  # def set_automation_db(self, mmt_id, auto_option='off'):
  #   """
  #   Set Similarity Check automation options for specific manuscript template using db
  #   :param: mmt_id: manuscript template id
  #   :param: auto_option: string: one of the options: 'off','at_first_full_submission',
  #   'after_major_revise_decision','after_minor_revise_decision','after_any_first_revise_decision'
  #   :return: void function
  #   """
  #   settings_id, settings_owner_id, settings_owner_type, settings_name, \
  #   settings_string_value, settings_type, settings_created_at, settings_updated_at, \
  #   settings_value_type, settings_setting_template_id = \
  #   PgSQL().query('SELECT settings.id, settings.owner_id, settings.owner_type, '
  #                 'settings.name, settings.string_value, settings.type, '
  #                 'settings.created_at, settings.updated_at, settings.value_type, '
  #                 'settings.setting_template_id'
  #                 'FROM task_templates, phase_templates, settings '
  #                 'WHERE phase_templates.manuscript_manager_template_id = %s '
  #                 'AND phase_templates.id=task_templates.phase_template_id '
  #                 'AND settings.owner_id=task_templates.id '
  #                 'AND task_templates.title= %s '
  #                 'AND settings.NAME = %s;', (mmt_id, 'Similarity Check',
  #                                             'ithenticate_automation'))[0]
  #   if auto_option != settings_string_value:
  #     PgSQL().modify('INSERT INTO settings (id, owner_id, owner_type, name, string_value, type, '
  #                    'created_at, updated_at, value_type, setting_template_id) '
  #                    'VALUES (%s, %s, %s, %s, %s, %s, '
  #                    'now(), now(), %s, %s);',
  #                    (settings_id, settings_owner_id, settings_owner_type, settings_name,
  #                     auto_option, settings_type, settings_created_at, settings_updated_at,
  #                     settings_value_type, settings_setting_template_id))


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
