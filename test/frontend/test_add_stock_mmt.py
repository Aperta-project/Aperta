#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case that populates all mmt needed for python test suite runs.
"""

import logging
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import super_admin_login, no_cards_mmt, gen_cmplt_apexdata, imgs_init_dec_mmt, \
  resrch_w_init_dec, research_mmt, front_matter_mmt, only_rev_cands_mmt, only_init_dec_mmt, \
  bio_essay, bio_resart, bio_genres, bio_mystery, bio_commpage, bio_formcomm, bio_nwc, gen_resart, \
  gen_persp
from Pages.admin import AdminPage
from Pages.journal_admin import JournalAdminPage

from frontend.common_test import CommonTest

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class ApertaSeedJournalMMTTest(CommonTest):
  """
  Self imposed AC:
  For PLOS Wombat (test journal)
     - Tests for and, if not present for journal PLOS Wombat, adds the following MMT to that
        journal:
          - NoCards
            usercards:  Upload Manuscript
            staffcards: Assign Team, Editor Discussion, Final Tech Check, Invite Academic Editor,
                        Invite Reviewers, Production Metadata, Register Decision, Related Articles,
                        Revision Tech Check, Send to Apex, Title And Abstract
            useresearchreviewerreport: True
          - generateCompleteApexData
            usercards:  Additional Information, Authors, Billing, Competing Interests, Cover Letter,
                        Data Availability, Ethics Statement, Figures, Financial Disclosure,
                        New Taxon, Reporting Guidelines, Reviewer Candidates, Supporting Info,
                        Upload Manuscript
            staffcards: Assign Team, Editor Discussion, Final Tech Check, Invite Academic Editor,
                        Invite Reviewers, Production Metadata, Register Decision, Related Articles,
                        Revision Tech Check, Send to Apex, Title And Abstract
            useresearchreviewerreport: True
          - Images+InitialDecision
            usercards:  Figures, Initial Decision, Upload Manuscript
            staffcards: Assign Team, Editor Discussion, Final Tech Check, Invite Academic Editor,
                        Invite Reviewers, Production Metadata, Register Decision, Related Articles,
                        Revision Tech Check, Send to Apex, Title And Abstract
            useresearchreviewerreport: True
          - Research w/Initial Decision Card
            usercards:  Authors, Billing, Cover Letter, Figures, Financial Disclosure,
                        Supporting Info, Upload Manuscript
            staffcards: Assign Admin, Initial Decision, Invite Academic Editor, Invite Reviewers,
                        Register Decision, Title And Abstract
            useresearchreviewerreport: True
          - Research
            usercards:  Authors, Billing, Cover Letter, Figures, Financial Disclosure,
                        Supporting Info, Upload Manuscript
            staffcards: Assign Admin, Invite Academic Editor, Invite Reviewers, Register Decision,
                        Title And Abstract
            useresearchreviewerreport: True
          - Front-Matter-type
            usercards:  Additional Information, Authors, Figures, Supporting Info, Upload Manuscript
            staffcards: Invite Reviewers, Production Metadata, Register Decision, Related Articles,
                        Send to Apex, Title And Abstract
            useresearchreviewerreport: False
          - OnlyReviewerCandidates
            usercards:  Reviewer Candidates, Upload Manuscript
            staffcards: Assign Team, Editor Discussion, Final Tech Check, Initial Tech Check,
                        Invite Academic Editor, Invite Reviewers, Production Metadata,
                        Register Decision, Related Articles, Revision Tech Check, Send to Apex,
                        Title And Abstract
            useresearchreviewerreport: True
          - OnlyInitialDecisionCard
            usercards:  Initial Decision, Upload Manuscript
            staffcards: Assign Team, Editor Discussion, Final Tech Check, Initial Tech Check,
                        Invite Academic Editor, Invite Reviewers, Register Decision,
                        Related Articles, Revision Tech Check, Send to Apex, Title And Abstract
            useresearchreviewerreport: True
  This test should be run second among test_add_superadmin (first), test_add_stock_mmt and
    test_add_stock_users_assignments (last).

  For PLOS Biology (test journal)
     - Tests for and, if not present for journal PLOS Biology, adds the following MMT to that
        journal:
          - Essay
            usercards:  Cover Letter, Upload Manuscript, Authors, Ethics Statement, Figures,
                        Reviewer Candidates, Supporting Info, Competing Interests,
                        Financial Disclosure, Additional Information
            staffcards: Initial Tech Check, Revision Tech Check, Final Tech Check,
                        Assign Team, Invite Academic Editor,
                        Invite Reviewers,
                        Register Decision,
                        Send to Apex, Production Metadata
            useresearchreviewerreport: True
          - Research Article
            usercards:  Upload Manuscript, Cover Letter, Figures, Supporting Info,
                        Additional Information
            staffcards: Assign Team, Initial Decision, Invite Academic Editor, Title And Abstract,
                        Initial Tech Check, Revision Tech Check, Final Tech Check,
                        Invite Reviewers,
                        Register Decision
                        Production Metadata, Ad hoc for Staff Only (named Copyedit - INTERNAL USE),
                        Ad hoc for Author (named Copyedit to Author),
                        Ad hoc (unknown type - named Proof Checklist),
                        Ad hoc (unknown type - named Proof Archive),
                        Send to Apex
            useresearchreviewerreport: True
          - Genetics Research
            usercards:  Additional Information, Authors, Billing, Competing Interests, Cover Letter,
                        Data Availability, Ethics Statement, Figures, Financial Disclosure,
                        Reporting Guidelines, Reveiwer Candidates, Supporting Info,
                        Upload Manuscript
            staffcards: Initial Tech Check, Revision Tech Check, Final Tech Check,
                        Assign Team, Invite Academic Editor,
                        Invite Reviewers,
                        Register Decision,
                        Send to Apex, Related Articles, Production Metadata
            useresearchreviewerreport: True
          - Unsolved Mystery
            usercards:  Cover Letter, Upload Manuscript, Authors, Ethics Statement, Figures,
                        Reviewer Candidates, Supporting Info, Competing Interests,
                        Financial Disclosure, Additional Information
            staffcards: Initial Tech Check, Revision Tech Check, Final Tech Check,
                        Assign Team, Invite Academic Editor,
                        Invite Reviewers,
                        Register Decision,
                        Send to Apex, Production Metadata
            useresearchreviewerreport: True
          - Community Page
            usercards:  Cover Letter, Upload Manuscript, Authors, Ethics Statement, Figures,
                        Reviewer Candidates, Supporting Info, Competing Interests,
                        Financial Disclosure, Additional Information
            staffcards: Initial Tech Check, Revision Tech Check, Final Tech Check,
                        Invite Academic Editor,
                        Invite Reviewers,
                        Register Decision,
                        Send to Apex, Production Metadata
            useresearchreviewerreport: True
          - Formal Comment
            usercards:  Cover Letter, Upload Manuscript, Authors, Ethics Statement, Figures,
                        Reviewer Candidates, Supporting Info, Competing Interests,
                        Financial Disclosure, Additional Information
            staffcards: Initial Tech Check, Revision Tech Check, Final Tech Check,
                        Assign Team, Invite Academic Editor,
                        Invite Reviewers,
                        Register Decision,
                        Send to Apex, Production Metadata
            useresearchreviewerreport: True
          - New Workflow Concept
            usercards:  Upload Manuscript, Supporting Info, Cover Letter, Additional Information,
                        Reviewer Candidates, Figures,
                        Authors, Ethics Statement, Data Availability, Competing Interests,
                        Financial Disclosure
            staffcards: Assign Team, Initial Decision, Title And Abstract,
                        Ad hoc (unknown type - named AE emails),
                        Ad hoc (unknown type - named Author Emails),
                        Inital Tech Check, Invite Reviewers,
                        Ad hoc (unknown type - named Reviewer Tracking and Chasing),
                        Ad hoc (unknown type - named Reviewer Email Templates),
                        Ad hoc (unknown type - named Rev 1 Round 1),
                        Ad hoc (unknown type - named Rev 2 Round 1),
                        Ad hoc (unknown type - named Emails to Reviewers),
                        Ad hoc (unknown type - named All new submission cards?),
                        Register Decision, Revision Tech Check, Invite Reviewers,
                        Ad hoc (unknown type - named Reviewer Emails),
                        Ad hoc (unknown type - named Reviewer Tracking and Chasing)
                        Ad hoc (unknown type - named Rev 1 Round 2),
                        Ad hoc (unknown type - named Rev 2 Round 2),
                        Ad hoc (unknown type - named All new submission cards?),
                        Register Decision, Final Tech Check, Production Metadata, Send to Apex,
                        Related Articles, Ad hoc (unknown type - named Proof Archive)
            useresearchreviewerreport: True

  For PLOS Genetics (test journal)
     - Tests for and, if not present for journal PLOS Genetics, adds the following MMT to that
        journal:
          - Research Article
            usercards:  Additional Information, Authors, Billing, Competing Interests, Cover Letter,
                        Data Availability, Ethics Statement, Figures, Financial Disclosure,
                        Reporting Guidelines, Reveiwer Candidates, Supporting Info,
                        Upload Manuscript
            staffcards: Initial Tech Check, Revision Tech Check, Final Tech Check,
                        Assign Team, Invite Academic Editor,
                        Invite Reviewers,
                        Register Decision,
                        Send to Apex, Related Articles, Production Metadata
            useresearchreviewerreport: True
          - Perspective
            usercards:  Cover Letter, Upload Manuscript, Authors, Figures, Supporting Info,
                        Competing Interests, Financial Disclosure, Additional Information
            staffcards: Initial Tech Check, Revision Tech Check, Final Tech Check,
                        Assign Team, Invite Academic Editor,
                        Invite Reviewers,
                        Register Decision,
                        Production Metadata, Send to Apex
            useresearchreviewerreport: False
  """
  def test_populate_base_mmts(self):
    """
    test_add_stock_mmt: adds the stock test MMT from the journal_admin page.
    Add new Templates if they don't exist
    :return: void function
    """
    qa_mmts = [only_init_dec_mmt, only_rev_cands_mmt, gen_cmplt_apexdata, front_matter_mmt,
                no_cards_mmt, imgs_init_dec_mmt, resrch_w_init_dec, research_mmt]
    logging.info('test_populate_base_mmts for QA')
    logging.info('Logging in as user: {0}, {1}'.format(super_admin_login['name'],
                                                       super_admin_login['email']))
    dashboard_page = self.cas_login(email=super_admin_login['email'])
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    wombat_exists = adm_page.select_named_journal('PLOS Wombat', click=True)
    logging.info(wombat_exists)
    if not wombat_exists:
      adm_page.validate_add_new_journal('asuperadm', journal_name='PLOS Wombat',
                                        journal_desc='Of, by and for the best marsupials',
                                        logo='WombatPVC_web-01.jpg', doi_jrnl_prefix='journal.pwom',
                                        doi_publ_prefix='10.1371', commit=True)
      adm_page.select_named_journal('PLOS Wombat', click=True)
      adm_page._populate_journal_db_values('PLOS Wombat', 'qa@plos.org')
    ja_page = JournalAdminPage(self.getDriver())
    time.sleep(1)
    for mmt in qa_mmts:
      # test if present, if not add
      mmt_present = ja_page.is_mmt_present(mmt['name'])
      if not mmt_present:
        logging.info('Adding MMT {0}'.format(mmt['name']))
        ja_page.add_new_mmt_template(commit=True,
                                     mmt_name=mmt['name'],
                                     user_tasks=mmt['user_tasks'],
                                     staff_tasks=mmt['staff_tasks'],
                                     uses_resrev_report=mmt['uses_resrev_report'])
        # It is necessary to reinvoke the driver to avoid a Stale Element Reference Exception
        #   as each new mmt add updates the DOM
        ja_page = JournalAdminPage(self.getDriver())

  def test_populate_biology_demo_mmts(self):
    """
    test_add_stock_mmt: adds the stock biology MMT from the journal_admin page.
    Add new Templates if they don't exist
    :return: void function
    """
    bio_mmts = [bio_essay, bio_resart, bio_genres, bio_mystery, bio_formcomm, bio_commpage, bio_nwc]
    logging.info('test_populate_base_mmts for Biology Demo')
    logging.info('Logging in as user: {0}, {1}'.format(super_admin_login['name'],
                                                       super_admin_login['email']))
    dashboard_page = self.cas_login(email=super_admin_login['email'])
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    biology_exists = adm_page.select_named_journal('PLOS Biology Demo', click=True)
    logging.info(biology_exists)
    if not biology_exists:
      adm_page.validate_add_new_journal('asuperadm', journal_name='PLOS Biology Demo',
                                        journal_desc='',
                                        logo='thumbnail_logo+plos+bio+2x.png',
                                        doi_jrnl_prefix='journal.pbiod',
                                        doi_publ_prefix='10.1371', commit=True)
      adm_page.select_named_journal('PLOS Biology Demo', click=True)
      adm_page._populate_journal_db_values('PLOS Biology Demo', 'noreply@plos.org')
    ja_page = JournalAdminPage(self.getDriver())
    time.sleep(1)
    for mmt in bio_mmts:
      # test if present, if not add
      mmt_present = ja_page.is_mmt_present(mmt['name'])
      if not mmt_present:
        logging.info('Adding MMT {0}'.format(mmt['name']))
        ja_page.add_new_mmt_template(commit=True,
                                     mmt_name=mmt['name'],
                                     user_tasks=mmt['user_tasks'],
                                     staff_tasks=mmt['staff_tasks'],
                                     uses_resrev_report=mmt['uses_resrev_report'])
        # It is necessary to reinvoke the driver to avoid a Stale Element Reference Exception
        #   as each new mmt add updates the DOM
        ja_page = JournalAdminPage(self.getDriver())

  def test_populate_genetics_demo_mmts(self):
    """
    test_add_stock_mmt: adds the stock genetics MMT from the journal_admin page.
    Add new Templates if they don't exist
    :return: void function
    """
    gen_mmts = [gen_resart, gen_persp]
    logging.info('test_populate_base_mmts for Genetics Demo')
    logging.info('Logging in as user: {0}, {1}'.format(super_admin_login['name'],
                                                       super_admin_login['email']))
    dashboard_page = self.cas_login(email=super_admin_login['email'])
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    genetics_exists = adm_page.select_named_journal('PLOS Genetics Demo', click=True)
    logging.info(genetics_exists)
    if not genetics_exists:
      adm_page.validate_add_new_journal('asuperadm', journal_name='PLOS Genetics Demo',
                                        journal_desc='',
                                        logo='thumbnail_plos_genetics_demo_logo.png',
                                        doi_jrnl_prefix='journal.pgend',
                                        doi_publ_prefix='10.1371', commit=True)
      adm_page.select_named_journal('PLOS Genetics Demo', click=True)
      adm_page._populate_journal_db_values('PLOS Genetics Demo', 'noreply@plos.org')
    ja_page = JournalAdminPage(self.getDriver())
    time.sleep(1)
    for mmt in gen_mmts:
      # test if present, if not add
      mmt_present = ja_page.is_mmt_present(mmt['name'])
      if not mmt_present:
        logging.info('Adding MMT {0}'.format(mmt['name']))
        ja_page.add_new_mmt_template(commit=True,
                                     mmt_name=mmt['name'],
                                     user_tasks=mmt['user_tasks'],
                                     staff_tasks=mmt['staff_tasks'],
                                     uses_resrev_report=mmt['uses_resrev_report'])
        # It is necessary to reinvoke the driver to avoid a Stale Element Reference Exception
        #   as each new mmt add updates the DOM
        ja_page = JournalAdminPage(self.getDriver())

  def rest_populate_support_demo_mmts(self):
    """
    test_add_stock_mmt: adds the stock support MMT from the journal_admin page.
    Add new Templates if they don't exist
    :return: void function
    """
    all_mmts = [only_init_dec_mmt, only_rev_cands_mmt, gen_cmplt_apexdata, front_matter_mmt,
                no_cards_mmt, imgs_init_dec_mmt, resrch_w_init_dec, research_mmt]
    logging.info('test_populate_base_mmts for Support Demo')
    logging.info('Logging in as user: {0}, {1}'.format(super_admin_login['name'],
                                                       super_admin_login['email']))
    dashboard_page = self.cas_login(email=super_admin_login['email'])
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    support_exists = adm_page.select_named_journal('PLOS Support', click=True)
    logging.info(support_exists)
    if not support_exists:
      adm_page.validate_add_new_journal('asuperadm', journal_name='PLOS Support',
                                        journal_desc='',
                                        logo='thumbnail_plos_demo.png',
                                        doi_jrnl_prefix='journal.psup',
                                        doi_publ_prefix='10.1371', commit=True)
      adm_page.select_named_journal('PLOS Support', click=True)
      adm_page._populate_journal_db_values('PLOS Support', 'noreply@plos.org')
    ja_page = JournalAdminPage(self.getDriver())
    time.sleep(1)
    for mmt in all_mmts:
      # test if present, if not add
      mmt_present = ja_page.is_mmt_present(mmt['name'])
      if not mmt_present:
        logging.info('Adding MMT {0}'.format(mmt['name']))
        ja_page.add_new_mmt_template(commit=True,
                                     mmt_name=mmt['name'],
                                     user_tasks=mmt['user_tasks'],
                                     staff_tasks=mmt['staff_tasks'],
                                     uses_resrev_report=mmt['uses_resrev_report'])
        # It is necessary to reinvoke the driver to avoid a Stale Element Reference Exception
        #   as each new mmt add updates the DOM
        ja_page = JournalAdminPage(self.getDriver())

  def rest_populate_prodstaff_demo_mmts(self):
    """
    test_add_stock_mmt: adds the stock prodstaff MMT from the journal_admin page.
    Add new Templates if they don't exist
    :return: void function
    """
    all_mmts = [only_init_dec_mmt, only_rev_cands_mmt, gen_cmplt_apexdata, front_matter_mmt,
                no_cards_mmt, imgs_init_dec_mmt, resrch_w_init_dec, research_mmt]
    logging.info('test_populate_base_mmts for Production Staff Demo')
    logging.info('Logging in as user: {0}, {1}'.format(super_admin_login['name'],
                                                       super_admin_login['email']))
    dashboard_page = self.cas_login(email=super_admin_login['email'])
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    prodstaff_exists = adm_page.select_named_journal('PLOS ProdStaff', click=True)
    logging.info(prodstaff_exists)
    if not prodstaff_exists:
      adm_page.validate_add_new_journal('asuperadm', journal_name='PLOS ProdStaff',
                                        logo='thumbnail_plos_demo.png',
                                        doi_jrnl_prefix='journal.pps',
                                        doi_publ_prefix='10.1371', commit=True)
      adm_page.select_named_journal('PLOS ProdStaff', click=True)
      adm_page._populate_journal_db_values('PLOS ProdStaff', 'noreply@plos.org')
    ja_page = JournalAdminPage(self.getDriver())
    time.sleep(1)
    for mmt in all_mmts:
      # test if present, if not add
      mmt_present = ja_page.is_mmt_present(mmt['name'])
      if not mmt_present:
        logging.info('Adding MMT {0}'.format(mmt['name']))
        ja_page.add_new_mmt_template(commit=True,
                                     mmt_name=mmt['name'],
                                     user_tasks=mmt['user_tasks'],
                                     staff_tasks=mmt['staff_tasks'],
                                     uses_resrev_report=mmt['uses_resrev_report'])
        # It is necessary to reinvoke the driver to avoid a Stale Element Reference Exception
        #   as each new mmt add updates the DOM
        ja_page = JournalAdminPage(self.getDriver())

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
