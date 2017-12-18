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
from Base.Resources import users, editorial_users, super_admin_login, handling_editor_login, \
    cover_editor_login, sim_check_full_submission_mmt, sim_check_major_revision_mmt, \
    sim_check_minor_revision_mmt, sim_check_first_revision_mmt
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
        adm_wf_page.click_on_card_settings(adm_wf_page._similarity_check_card)

        card_settings = SimCheckSettings(self.getDriver())
        card_settings.overlay_ready()
        card_settings.validate_card_setting_style('Similarity Check: Settings')
        card_settings.validate_setting_style_and_components()

        card_settings.click_cancel()

    def rest_smoke_generate_manually_and_validate_access(self):
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

        logging.info('Test Similarity Check with Automation Off:: generate report '
                     'manually and validate access')

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

        # log as editorial user
        staff_user = random.choice(editorial_users)
        logging.info('Logging in as user: {0}'.format(staff_user['name']))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.go_to_manuscript(short_doi)
        self._driver.navigated = True

        paper_viewer = ManuscriptViewerPage(self.getDriver())
        paper_viewer.page_ready()
        # AC#2 - check the card appears only in workflow view, not in manuscript view
        assert not paper_viewer.is_task_present("Similarity Check"), \
            "Similarity Check card should not be available in Manuscript view"
        # go to Workflow view
        paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
        paper_viewer.click_workflow_link()
        workflow_page = WorkflowPage(self.getDriver())
        workflow_page.page_ready()

        auto_setting_default = 'off'
        # get auto settings from db, it is expected to be off by default
        auto_settings_db = workflow_page.get_sim_check_auto_settings(short_doi=short_doi,
                                                                     from_admin_mmt=False)
        assert auto_settings_db == 'off', 'Automation setting in db: \'{0}\' is not ' \
                                          'the expected: \'{1}\''.format(auto_settings_db,
                                                                         auto_setting_default)

        workflow_page.click_card('similarity_check')
        sim_check = SimilarityCheckCard(self.getDriver())
        sim_check.card_ready()
        # sim_check._wait_for_element(sim_check._get(sim_check._decision_labels))
        sim_check.validate_card_header(short_doi)
        sim_check.validate_styles_and_components(
            auto_setting_default)  # generating report is triggered by submission manuscript
        # if not auto_settings == 'at_first_full_submission':
        #   sim_check.generate_manual_report()

        task_url, start_time = sim_check.generate_manual_report()
        sim_check.logout()

        # Similarity checks may take up to several minutes to complete,
        # so we'll use this time to run  access validation test
        logging.info("Switching to Access validation test at: {0}"
                     .format(start_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ')))
        self.validate_access(staff_user)

        finish_time = datetime.now()
        diff_time = finish_time - start_time

        seconds = diff_time.seconds
        logging.info("Access validation test finished at: {0}"
                     .format(finish_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ')))

        logging.info('Elapsed time in seconds: {0}'.format(str(seconds)))

        #
        # log as staff_user
        logging.info('Logging in as user: {0} to validate similarity check report'
                     .format(staff_user['name']))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        self._driver.get(task_url)  # go_to_manuscript(short_doi)
        # self._driver.navigated = True

        # paper_viewer = ManuscriptViewerPage(self.getDriver())
        # paper_viewer.page_ready()
        sim_check = SimilarityCheckCard(self.getDriver())
        sim_check.card_ready()
        report_validation_result = sim_check.validate_report_result()
        if not report_validation_result:
            assert 'Report not available:' in report_validation_result


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
        dashboard_page.page_ready()
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

        # set handler_and_cover_assigned to false to make sure handling and cover editors
        # assigned only one time
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
                                                     "I AM DONE WITH THIS TASK"], \
                completed_section_button.text

            # assign cover editor and handling editor to test their access to the card
            if not handler_and_cover_assigned:  # just to be sure we do it once
                sim_check.click_close_button_bottom()
                workflow_page._wait_on_lambda(lambda: workflow_page.get_current_url()
                                              .split('/')[-1] == 'workflow')
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
        helping_editors = [cover_editor_login, handling_editor_login]
        for staff_user in helping_editors:
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

    def test_core_trigger_automated_report(self):
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

        logging.info('Test Similarity Check with Automation ON:: generate report '
                     'manually and validate access')
        auto_options = (('at_first_full_submission',sim_check_full_submission_mmt['name']),
                        ('after_major_revise_decision',sim_check_major_revision_mmt['name']),
                        ('after_minor_revise_decision',sim_check_minor_revision_mmt['name']),
                        ('after_any_first_revise_decision',sim_check_first_revision_mmt['name']))


        auto_setting = auto_options[0] # random.choice(auto_options)
        auto_option = auto_setting[0]
        mmt_name = auto_setting[1]

        # self._set_automation_ui('Similarity Check test', auto_option=auto_settings)

        # log as an author and create new submission
        creator_user = random.choice(users)
        dashboard_page = self.cas_login(email=creator_user['email'])
        dashboard_page.click_create_new_submission_button()
        title = 'Similarity Check test with auto trigger'
        # TODO: use random file
        doc_to_use = 'frontend/assets/docs/Preclinical_Applications_of_3-Deoxy-3-18F_Fluorothymidine_in_Oncology-A_Systematic_.docx'
        self.create_article(title=title, journal='PLOS Wombat', type_=mmt_name,
                            document=doc_to_use,
                            random_bit=True, format_='word')
        #
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready()
        short_doi = manuscript_page.get_paper_short_doi_from_url()
        paper_url = manuscript_page.get_current_url_without_args()
        logging.info("Assigned paper short doi: {0}".format(short_doi))
        # Complete cards
        manuscript_page.complete_task('Upload Manuscript')
        manuscript_page.complete_task('Title And Abstract')
        manuscript_page.click_submit_btn()
        manuscript_page.confirm_submit_btn()
        manuscript_page.close_submit_overlay()
        # logout
        manuscript_page.logout()

        # log as editorial user
        staff_user = random.choice(editorial_users)
        logging.info('Logging in as user: {0}'.format(staff_user['name']))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        # navigate directly to manuscript workflow view
        paper_workflow_url = '{0}/workflow'.format(paper_url)
        self._driver.get(paper_workflow_url)
        workflow_page = WorkflowPage(self.getDriver())
        workflow_page.page_ready()

        workflow_page.click_card('similarity_check')
        sim_check = SimilarityCheckCard(self.getDriver())
        sim_check.card_ready()
        if auto_option == 'at_first_full_submission':
            # sim_check.validate_report_result()
            start_time = datetime.now()
            report_validation_result = sim_check.validate_report_result()
            finish_time = datetime.now()
            diff_time = finish_time - start_time
            seconds = diff_time.seconds
            logging.info("Report result validation finished at: {0}"
                         .format(finish_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ')))
            logging.info('Elapsed time in seconds: {0}'.format(str(seconds)))
            if report_validation_result:
                assert 'Report not available:' in report_validation_result


if __name__ == '__main__':
    CommonTest._run_tests_randomly()
