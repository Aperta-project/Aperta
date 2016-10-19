#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case that populates all mmt needed for python test suite runs.
"""

import logging
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import super_admin_login, no_cards_mmt, gen_cmplt_apexdata, imgs_init_dec_mmt, \
  resrch_w_init_dec, research_mmt, front_matter_mmt, only_rev_cands_mmt, only_init_dec_mmt
from Pages.admin import AdminPage
from Pages.journal_admin import JournalAdminPage

from frontend.common_test import CommonTest

__author__ = 'jgray@plos.org'


@MultiBrowserFixture
class ApertaSeedJournalMMTTest(CommonTest):
  """
  Self imposed AC:
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
  """
  def test_populate_base_mmts(self):
    """
    test_add_stock_mmt: adds the stock test MMT from the journal_admin page.
    Add new Templates if they don't exist
    :return: void function
    """
    all_mmts = [only_init_dec_mmt, only_rev_cands_mmt, gen_cmplt_apexdata, front_matter_mmt,
                no_cards_mmt, imgs_init_dec_mmt, resrch_w_init_dec, research_mmt]
    logging.info('test_populate_base_mmts')
    logging.info('Logging in as user: {0}, {1}'.format(super_admin_login['name'],
                                                       super_admin_login['email']))
    dashboard_page = self.cas_login(email=super_admin_login['email'])
    dashboard_page.click_admin_link()

    adm_page = AdminPage(self.getDriver())
    wombat_exists = adm_page.select_named_journal('PLOS Wombat', click=True)
    logging.info(wombat_exists)
    if not wombat_exists:
      adm_page.validate_add_new_journal('asuperadm',
                                        journal_name='PLOS Wombat',
                                        journal_desc='Of, by and for the best marsupials',
                                        logo='WombatPVC_web-01.jpg',
                                        commit=True)
      adm_page.select_named_journal('PLOS Wombat', click=True)
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
