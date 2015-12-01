#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This behavioral test case validates the Aperta Create New Submission through Submit process.
"""
__author__ = 'jgray@plos.org'

import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_pw, au_login, rv_login, fm_login, ae_login, he_login, sa_login, oa_login
from frontend.Cards.figures_card import FiguresCard
# from frontend.Cards.supporting_info_card import SupportingInfoCard
# from frontend.Cards.upload_manuscript_card import UploadManuscriptCard
from frontend.common_test import CommonTest
from Pages.dashboard import DashboardPage
from Pages.login_page import LoginPage
from Pages.manuscript_page import ManuscriptPage

# au and sa are commented out because they run into APERTA-5415 which is a code bug
users = [au_login]

docs = ['10yearsRabiesSL20140723.doc',
        '11-OvCa-Collab-HeightBMI-paper-July.doc',
        '120220_PLoS_Genetics_review.docx',
        '2011_10_28_PLOS-final.doc',
        '2014_04_27 Bakowski et al main text_subm.docx',
        'Aedes hensilli vector capacity - final-3 - clean - plosntd.doc',
        'April editorial 2012.doc',
        'C6 Text Final.doc',
        'CRX.pone.0103411.docx',
        'Chemical Synthesis of Bacteriophage G4.doc',
        'Commentary Jan 19 2012.docx',
        'EGFR PLOS GENETICS.docx',
        'GIANT-gender-main_20130310.docx',
        'Hamilton_Yu_121611.doc',
        'Hotez - NTDs 2 0 shifting policy landscape PLOS NTDs figs extracted for submish.docx',
        'IPDms1 textV5.doc',
        'IPTc Review FINAL v5 100111_clean.doc',
        'Institutional Predictors - 8 14 clean copy (1)_HB_MW.docx',
        'July Blue Marble Editorial final for accept 16June.docx',
        'LifeExpectancyART10 PM RM edits_FINAL.doc',
        'Manuscript Monitoring HIV Viral Load in Resource Limited PLoSONE-1_MA 28082012.docx',
        'Manuscript revised final.doc',
        'Manuscript_resubmission_1 April2014_REVISED.docx',
        'ModularModeling-PLoSCompBioPerspective_2ndREVISION.doc',
        'Moon and Wilusz - PLoS Pearl REVISED Version FINAL 9-25.docx',
        'Ms clean.docx',
        'NF-kB-Paper_manuscript.docx',
        'NLP-PLoS4Unhighlighted.doc',
        'NMR for submission 7 Feb 2011.doc',
        'Nazzi ms def.doc',
        'NonMarked_Maxwell_PLoSBiol_060611.doc',
        'NorenzayanetalPLOS.docx',
        'PGENETICS-D-13-02065R1_FTC.docx',
        'PLOS Comp Bio Second Revision.docx',
        'PLP D-14-00383R1-7.9.14.doc',
        'PLoS - ACUDep Primary Clinical Results - version12- 6August2013 - final.docx',
        'PLoS article.doc',
        'PLosOne_Main_Body_Ravi_Bansal_Brad_REVISED.docx',
        'PNTD-D-12-00578_Revised manuscript Final_(5.9.2012).doc',
        'PONE-D-12-25504.docx',
        'PONE-D-12-27950.docx',
        'PONE-D-12-30946.doc',
        'PONE-D-13-00751.doc',
        'PONE-D-13-02344.docx',
        'PONE-D-13-04452.doc',
        'PONE-D-13-11786.doc',
        'PONE-D-13-14162.docx',
        'PONE-D-13-19782.docx',
        'PONE-D-13-38666.docx',
        'PONE-D-14-12686.docx',
        'PONE-D-14-17217.docx',
        'PPATHOGENS-D-14-01213.docx',
        'Pope et al., revised 11-12-10.docx',
        'RTN.pone.0072333.docx',
        'Revisedmanuscript11 (1).doc',
        'Rohde PLoS Pathogens.doc',
        'Schallmo_PLOS_RevisedManuscript.docx',
        'Sialyllactose_Final_PLoS.pdf',
        'Spindler_2014_rerevised.docx',
        'Stroke review resubmission4_LR.docx',
        'Text Mouillot et al. Plos Biology Final3RJ.docx',
        'Thammasri_PONE_D13_12078_wo.docx',
        'chiappini et al.doc',
        'docs.tar.gz',
        'importeddoslinefeeds.docx',
        'importedunixlinefeeds.docx',
        'iom_essay02.doc',
        'manuscript clean.doc',
        'manuscript.doc',
        'paper.bib',
        'paper.tex',
        'pgen.1004127.docx',
        'pone.0100365.docx',
        'pone.0100948.docx',
        'ppat.1004210.docx',
        'resubmission_text_ethics changed.doc',
        'sample.docx',
        'tbParBSASpl1.docx',
        ]

cards = ['cover_letter',
         'billing',
         'figures',
         'authors',
         'supporting_info',
         'upload_manuscript',
         'prq',
         'review_candidates',
         'revise_task',
         'competing_interests',
         'data_availability',
         'ethics_statement',
         'financial_disclosure',
         'new_taxon',
         'reporting_guidelines',
         'changes_for_author',
         ]


@MultiBrowserFixture
class ApertaBDDCNStoSubmitTest(CommonTest):
  """
  Self imposed AC:
    log in as author
    Aperta takes you to Dashboard
    click “create new submission”
    enter a title
    select the journal that you are submitting to
    choose the journal PLOS Wombat
    choose the type of paper (Research)
    drag manuscript/attach to “upload manuscript” or click “upload manuscript” to upload manuscript
    end up on the manuscript page
    begin working through the cards on the right-hand side (don’t have to go in order that they are displayed)
    general
    after you complete each card, check “complete” and “close” to return to manuscript page
    for a few cards, try to:
    check complete and close and then reopen to make sure that the comments saved
    don’t check complete, close and then reopen to see if the comments saved (everything should save)
    billing
    enter payee details
    select how you would like to pay
    cover letter
    paste in cover letter
    upload manuscript
    should be complete already (gray) but if not, upload the manuscript here
    figures
    check “yes, I confirm…”
    add new figures
    once figure is uploaded, enter figure captions\
    click “save”
    upload 1-2 figures
    one tiff and one eps
    ethics statement
    answer questions 1 and 2 and provide explanations when prompted
    reviewer candidates
    enter reviewer details for 2 reviewers (either recommend or oppose)
    enter a reviewer who doesn’t have an account in Aperta
    enter a reviewer who does have an account in Aperta
    confirm that the editor receives the reviewer recommendation card as it was completed by the submitting author
    reporting guidelines
    check Systematic Review or Meta-Analysis
    select and upload word doc
    supporting info
    “add new supporting information”
    add a title
    add a caption
    try uploading a docx, an excel file, pdf, ppt and any image file
    financial disclosures
    answer question “yes” and add 2 funders
    enter funder information
    indicate that one of them has a role in study design and input descriptoin
    be sure to confirm that the funder name appears appropriately in the published financial disclosure statement that is indicated at the bottom
    confirm that once a website is added to the funder information, a hyperlink is automatically created (associated to funder name below)
    authors
    add a corresponding author
    add one additional authors
    should be able to search an institution/affiliations
    publishing related questions
    select “yes” for at least one of the questions and provide the necessary information
    check to see if you are able to complete the card without providing certain information
    data availability
    doesn’t matter if you select “yes” or “no”
    competing interests
    answer yes, provide statement
    once you’ve completed all cards, check to make sure that all cards appear gray
    Hit SUBMIT and confirm

  """
  def test_validate_components_styles(self):
    """
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission
    """
    user_type = random.choice(users)
    print('Logging in as user: ' + user_type)
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(user_type)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()

    dashboard_page = DashboardPage(self.getDriver())
    # Validate Create New Submissions modal
    dashboard_page.click_create_new_submission_button()
    # We recently became slow drawing this overlay (20151006)
    time.sleep(2)
    title = dashboard_page.title_generator()
    dashboard_page.enter_title_field(title)
    # This should be expanded to make a random choice of journal and a random choice within that journal of type
    # NOTA BENE: Despite the options in the overlay including leading and trailing spaces, this must be called stripped
    #    of the same
    # dashboard_page.select_journal_and_type('PLOS Wombat', 'MinimalMMTforCreatetoSubmitAT')
    dashboard_page.select_journal_and_type('PLOS Wombat', 'Research')
    time.sleep(3)
    doc2upload = random.choice(docs)
    print('Sending document: ' + os.path.join(os.getcwd() + '/frontend/assets/docs/' + doc2upload))
    fn = os.path.join(os.getcwd() + '/frontend/assets/docs/' + doc2upload)
    self._driver.find_element_by_id('upload-files').send_keys(fn)
    dashboard_page.click_upload_button()
    # Wait for progress spinner
    # Need to figure out a locator for the spinner and text

    # Time needed for iHat conversion.
    time.sleep(5)

    # manuscript_page = ManuscriptPage(self.getDriver())
    #
    # manuscript_page.click_card(figures)
    # time.sleep(3)
    # figures_card = FiguresCard(self.getDriver())
    # figures_card.click_completed_checkbox()
    # figures_card.click_close_button()
    # time.sleep(3)


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
