#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This test case validates style and function of Similarity Check
"""
import logging
import os
import random
import time

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.Resources import users, editorial_users, admin_users, super_admin_login
from frontend.common_test import CommonTest
from .Cards.similarity_check_card import SimilarityCheckCard
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.workflow_page import WorkflowPage
from .Pages.admin_workflows import AdminWorkflowsPage
from .Pages.sim_check_settings import SimCheckSettings

__author__ = 'gtimonina@plos.org'


@MultiBrowserFixture
class SimilarityCheckTest(CommonTest):
  """
  Validate the elements, styles, functions of the Similarity Check card
  """

  def rest_settings_validate_components_styles(self):
    """
    test_admin: Validate elements and styles for the base Similarity Check page
    :return: void function
    """
    logging.info('Test Similarity Check::validate_components_styles')
    logging.info('Validating Similarity Check page components and styles')
    user_type = super_admin_login
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    dashboard_page.click_admin_link()
    adm_wf_page = SimCheckSettings(self.getDriver())
    adm_wf_page.page_ready()
    adm_wf_page.open_mmt('Similarity Check test')

    adm_wf_page.click_on_card_settings(adm_wf_page._sim_check_card_settings)
    adm_wf_page.validate_setting_style_and_components()

    adm_wf_page.close_overlay()
    #adm_wf_page.close_mmt_card()



  def test_smoke_sim_check_default(self):
    """
    test_core_sim_check_default: Validates the similarity check card presence,
    form elements and styles.
    :return: void function
    """
    #
    # the card appears only in Workflow view
    current_path = os.getcwd()
    logging.info(current_path)

    # log as an author and create new submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.click_create_new_submission_button()
    title = 'For Similarity Check test'
    self.create_article(title=title, journal='PLOS Wombat', type_='Similarity Check test', random_bit=True, format_='word')
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
    logging.info('Logging in as user: {0}'.format(staff_user['name']))
    dashboard_page = self.cas_login(email=staff_user['email'])
    cns_button = dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn)
    dashboard_page._wait_for_element(cns_button)
    dashboard_page.go_to_manuscript(short_doi)
    self._driver.navigated = True
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # AC#2 - check the card appears only in workflow view
    assert not paper_viewer.is_task_present("Similarity Check"), "Similarity Check card should not be " \
                                                                 "available in Manuscript view"
    # go to Workflow view
    paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
    paper_viewer.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))

    # # separate test case? #
    # workflow_page.click_add_new_card()
    # time.sleep(2)
    # staff_cards = workflow_page._gets(workflow_page._mmt_staff_cards)
    # # filter cards under staff cards column to find all that have 'Similarity Check' in the name
    # sim_check_card_items = list(filter(lambda x: 'Similarity Check' in x.text, staff_cards))
    # assert len(sim_check_card_items)==1, 'There is {0} Similarity Check card under Staff task card column, ' \
    #                                      'expected: 1'.index(format(len(sim_check_card_items)))
    # # add Similarity Check card to Workflow template
    # # workflow_page.add_card('Similarity Check')
    # close_icon_overlay = workflow_page._get(workflow_page._overlay_header_close)
    # close_icon_overlay.click()
    # workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
    # ##

    # get auto settings from db
    auto_settings = workflow_page.get_sim_check_auto_settings(short_doi = short_doi, from_admin_mmt = False)

    workflow_page.click_card('similarity_check')
    sim_check = SimilarityCheckCard(self.getDriver())
    sim_check.card_ready()
    #sim_check._wait_for_element(sim_check._get(sim_check._decision_labels))
    sim_check.validate_card_header(short_doi)
    sim_check.validate_styles_and_components(auto_settings) # generating report is triggered by submission manuscript
    if not auto_settings == 'at_first_full_submission':
      sim_check.generate_manual_report()
    sim_check.validate_report_result()


  def rest_core_validate_access(self):
    """
    test_core_validate_access: Validates that any editorial users have access to the Similarity Check card
    :return: void function
    """
    # log as author and create new submission  using test workflow
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.click_create_new_submission_button()
    title = 'For Similarity Check test'
    self.create_article(title=title, journal='PLOS Wombat', type_='Similarity Check test', random_bit=True)
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

    # log as editorial users
    for staff_user in editorial_users:
      logging.info('Logging in as user: {0}'.format(staff_user['name']))
      dashboard_page = self.cas_login(email=staff_user['email'])
      cns_button = dashboard_page._get(dashboard_page._dashboard_create_new_submission_btn)
      dashboard_page._wait_for_element(cns_button)
      dashboard_page.go_to_manuscript(short_doi)
      self._driver.navigated = True
      paper_viewer = ManuscriptViewerPage(self.getDriver())
      # go to Workflow view
      paper_viewer._wait_for_element(paper_viewer._get(paper_viewer._tb_workflow_link))
      paper_viewer.click_workflow_link()
      workflow_page = WorkflowPage(self.getDriver())
      workflow_page._wait_for_element(workflow_page._get(workflow_page._add_new_card_button))
      #
      workflow_page.click_card('similarity_check')
      sim_check = SimilarityCheckCard(self.getDriver())
      sim_check.card_ready()
      #
      # sim_check.validate_card_header(short_doi)
      card_title = sim_check._get(sim_check._card_heading)
      assert card_title.text == 'Similarity Check'
      sim_check.validate_generate_report_button()
      # logout
      sim_check.logout()


  def rest_validate_sim_check_card(self):

    # logging.info('Test Similarity Check::validate card')
    current_path = os.getcwd()
    logging.info(current_path)


    #
    logging.info('Test Similarity Check::validate card')
    self.open_wf_with_sim_check(card_name='Similarity Check test', auto_option='OFF')

    #
    logging.info('Test Similarity Check::automated check after first full submission')
    self.open_wf_with_sim_check(card_name='Similarity Check test', auto_option='ON', on_submission=True)

    #
    logging.info('Test Similarity Check::automated check after first major revision')
    self.open_wf_with_sim_check(card_name='Similarity Check test', auto_option='ON', on_submission=False,
                                after_revision = ['major revision',0])

   #
    logging.info('Test Similarity Check::automated check after first minor revision')
    self.open_wf_with_sim_check(card_name='Similarity Check test', auto_option='ON', on_submission=False,
                                after_revision = ['minor revision',1])

    #
    logging.info('Test Similarity Check::automated check after any first revision')
    self.open_wf_with_sim_check(card_name='Similarity Check test', auto_option='ON', on_submission=False,
                                after_revision=['any first revision', 2])


  def open_wf_with_sim_check(self, card_name='Similarity Check test', auto_option='OFF', on_submission=None, after_revision=None):
    """
    function to open test workflow with Similarity Check Card and set specified settings
    :return: None
    """
    # #log as superadmin and open workflow with Similarity Check card
    # user_type = super_admin_login
    # logging.info('Logging in as user: {0}'.format(user_type))
    # dashboard_page = self.cas_login(email=user_type['email'])
    # dashboard_page.click_admin_link()

    adm_wf_page = SimCheckSettings(self.getDriver())   #AdminWorkflowsPage(self.getDriver())
    adm_wf_page.page_ready()
    #adm_wf_page.select_named_journal('PLOS Wombat')
    adm_wf_page.open_mmt(card_name)
    adm_wf_page.click_on_card_settings(adm_wf_page._sim_check_card_settings)

    #sim_check_settings = SimilarityCheckCard(self.getDriver())
    if auto_option=='OFF':
      adm_wf_page.set_automation(automation=False)
    else:
      adm_wf_page.set_automation(automation=True)
      if on_submission:
        adm_wf_page.set_automation_after_submission(0) # after first submission
      else:
        adm_wf_page.set_automation_after_submission(1) # after revision
        adm_wf_page.select_and_validate_after_revision_option(after_revision[0], after_revision[1])

    adm_wf_page.save_settings() # save and close settings overlay
    #time.sleep(1)
    adm_wf_page._wait_for_element(adm_wf_page._get(adm_wf_page._mmt_template_back_link))
    adm_wf_page.close_mmt_card()
    #adm_wf_page._wait_for_element(adm_wf_page._admin_workflow_pane_title)
    #adm_wf_page.logout()
    #




if __name__ == '__main__':
  CommonTest._run_tests_randomly()
