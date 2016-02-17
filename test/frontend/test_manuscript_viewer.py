#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the article editor page and its associated overlays.
"""
__author__ = 'sbassi@plos.org'

import logging
import time
import random
import os

from Base.Decorators import MultiBrowserFixture
from Base.CustomException import ElementDoesNotExistAssertionError
from Pages.login_page import LoginPage
from Base.Resources import login_valid_pw, au_login, rv_login, fm_login, ae_login, \
  he_login, sa_login, oa_login, co_login
from Base.PostgreSQL import PgSQL
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.dashboard import DashboardPage
from Pages.workflow_page import WorkflowPage
from Cards.initial_decision_card import InitialDecisionCard
from frontend.common_test import CommonTest, docs

users = (au_login,
         rv_login,
         ae_login,
         he_login,
         sa_login,
         oa_login)

@MultiBrowserFixture
class ViewPaperTest(CommonTest):
  """
  This class implements:
    APERTA-5515
    APERTA-3
  """

  def test_validate_components_styles(self):
    """
    APERTA-3: validate page elements and styles
    Validates the presence of the following elements:
      - icons in text area (editor menu)
      - button for comparing versions
      - button for adding collaborators
      - button for paper download
      - button for recent activity
      - button for discussions
      - button for worflow
      - button for more options
    """
    article_title = self.select_preexisting_article(first=True)
    manuscript_viewer = ManuscriptViewerPage(self.getDriver())
    manuscript_viewer.validate_page_elements_styles_functions()
    return self

  def _test_role_aware_menus(self):
    """
    APERTA-3: Validates role aware menus

    Note: Test disabled until APERTA-5992 is fixed
    """
    roles = {au_login['user']: 7,
             rv_login['user']: 7,
             ae_login['user']: 7,
             he_login['user']: 8,
             sa_login['user']: 8,
             oa_login['user']: 8}

    for user in users:
      logging.info('Logging in as user: {}'.format(user))
      logging.info('role: {}'.format(roles[user['user']]))
      uid = PgSQL().query('SELECT id FROM users where username = %s;', (user['user'],))[0][0]
      login_page = LoginPage(self.getDriver())
      login_page.enter_login_field(user['user'])
      login_page.enter_password_field(login_valid_pw)
      login_page.click_sign_in_button()
      # the following call should only succeed for sa_login
      dashboard_page = DashboardPage(self.getDriver())
      dashboard_page.set_timeout(120)
      if dashboard_page.validate_manuscript_section_main_title(user['user']) > 0:
        dashboard_page.restore_timeout()
        self.select_preexisting_article(init=False, first=True)
        manuscript_viewer = ManuscriptViewerPage(self.getDriver())
        time.sleep(3) # needed to give time to retrieve new menu items
        if user['user'] == ae_login['user']:
          paper_id = manuscript_viewer.get_paper_db_id()
          permissions = PgSQL().query('SELECT paper_roles.old_role FROM paper_roles '
                              'where user_id = %s and paper_id = %s;',
                              (uid, paper_id)
                              )
          for x in permissions:
            if ('editor',) == x:
              roles[user['user']] = 8
        manuscript_viewer.validate_roles(roles[user['user']])
        url = self._driver.current_url
        signout_url = url[:url.index('/papers/')] + '/users/sign_out'
      else:
        dashboard_page.restore_timeout()
        logging.info('No manuscripts present for user: {}'.format(user['user']))
        # Logout
        url = self._driver.current_url
        signout_url = '{}/users/sign_out'.format(url)
      self._driver.get(signout_url)
    return self

  def test_initial_submission_infobox(self):
    """
    Aperta-5515

    AC from Aperta-5515:
      1. When the page is opened for first time, check for info box.
      2. Test closing the info box
      3. Info box appears for initial manuscript view only, whether the user closes or leaves it open
      4. Info box does not appear for Collaborators
      5. Message for initial submission when there are still cards to fill
      6. Message for initial submission when is ready for submission
      7. Message for full submission when there are still cards to fill
      8. Message for full submission when is ready for submission
      9. Show "[Journal Name] submission process (?)" on top of the card stack at all times.
      10. Clicking the question mark opens the "[Journal Name] submission process" info box

    Notes:
      AC#4 disabled until APERTA-5987 is fixed
      AC#7 on hold until APERTA-5718 is fixed.
      AC#10 on hold until APERTA-5725 is fixed
    """
    logging.info('Logging in as user: {}'.format(au_login))
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(au_login['user'])
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    # the following call should only succeed for sa_login
    dashboard_page = DashboardPage(self.getDriver())
    # create a new manuscript
    dashboard_page.click_create_new_submission_button()
    # We recently became slow drawing this overlay (20151006)
    time.sleep(.5)
    # Temporary changing timeout
    dashboard_page.set_timeout(120)
    title = self.create_article(journal='PLOS Wombat',
                                type_='Images+InitialDecision',
                                random_bit=True,
                                init=False,
                                )
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # AC1 Test for info box
    infobox = manuscript_page.get_infobox()
    dashboard_page.restore_timeout()
    # Note: Request title to make sure the required page is loaded
    paper_url = manuscript_page.get_current_url()
    logging.info('The paper ID of this newly created paper is: {}'.format(paper_url))
    paper_id = paper_url.split('papers/')[1]
    # AC5 Test for Message for initial submission
    assert "Please provide the following information to submit your manuscript for "\
            "Initial Submission." in manuscript_page.get_submission_status_info_text(),\
            manuscript_page.get_submission_status_info_text()
    # AC2 Test closing the infobox
    infobox.find_element_by_id('sp-close').click()
    time.sleep(3)
    manuscript_page.set_timeout(1)
    try:
      manuscript_page.get_infobox()
    except ElementDoesNotExistAssertionError:
      assert True
    else:
      assert False, "Infobox still open. AC2 fails"
    manuscript_page.restore_timeout()
    # AC3 Green info box appears for initial manuscript view only - whether the user closes or leaves it open
    manuscript_page.click_dashboard_link()
    self._driver.get(paper_url)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # Note: Request title to make sure the required page is loaded
    manuscript_page.set_timeout(20)
    manuscript_page.get_paper_title_from_page()
    manuscript_page.restore_timeout()
    manuscript_page.set_timeout(.5)
    try:
      manuscript_page.get_infobox()
    except ElementDoesNotExistAssertionError:
      assert True
    else:
      assert False, "Infobox still open. AC3 fails"
    manuscript_page.restore_timeout()
    # Open infobox with question mark icon. AC#10
    manuscript_page.click_question_mark()
    manuscript_page.get_infobox()

    ##dashboard_page.click_on_first_manuscript()
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # Add a collaborator (for AC4)
    manuscript_page.add_collaborators(rv_login)
    paper_id = manuscript_page.get_current_url().split('/')[-1]
    # Complete IMG card to force display of submission status project
    time.sleep(1)
    print('Opening the Figures task')
    manuscript_page.click_task('Figures')
    time.sleep(5)
    manuscript_page.complete_task('Figures')
    manuscript_page.click_task('Figures')
    # NOTE: At this point browser renders the page with errors only on automation runs
    # AC 6
    assert "Your manuscript is ready for Initial Submission." in \
            manuscript_page.get_submission_status_info_text(),\
            manuscript_page.get_submission_status_info_text()
    manuscript_page.logout()
    # Following block disabled due to APERTA-5987
    """
    # Loging as collaborator
    dashboard_page = self.login(email=rv_login['user'], password=login_valid_pw)
    dashboard_page.go_to_manuscript(paper_id)
    time.sleep(1)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.set_timeout(.5)
    # AC4 Green info box does not appear for collaborators
    try:
      manuscript_page.get_infobox()
    except ElementDoesNotExistAssertionError:
      assert True
    else:
      assert False, "Infobox still open. AC4 fails"
    manuscript_page.restore_timeout()
    # Submit
    """
    # Start temporaty worfaround until APERTA-5987 is fixed
    dashboard_page = self.login(email=sa_login['user'], password=login_valid_pw)
    dashboard_page.go_to_manuscript(paper_id)
    time.sleep(1)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # End temporaty worfaround until APERTA-5987 is fixed
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_modal()
    # Aprove initial Decision
    manuscript_page.logout()
    logging.info('Logging in as user: {}'.format(sa_login))
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(sa_login['user'])
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    # the following call should only succeed for sa_login
    dashboard_page = DashboardPage(self.getDriver())
    dashboard_page.go_to_manuscript(paper_id)
    time.sleep(1)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_workflow_lnk()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.click_card('initial_decision')
    initial_decision_card = InitialDecisionCard(self.getDriver())
    initial_decision_card.execute_decision('invite')
    initial_decision_card.click_close_button()
    time.sleep(2)
    manuscript_page.logout()
    # Test for AC8
    logging.info('Logging in as user: {}'.format(au_login))
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(au_login['user'])
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    # the following call should only succeed for sa_login
    dashboard_page = DashboardPage(self.getDriver())
    dashboard_page.go_to_manuscript(paper_id)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    #AC8: Message for full submission when is ready for submition
    manuscript_page._get(manuscript_page._nav_dashboard_link)
    time.sleep(5)
    assert  "Your manuscript is ready for Full Submission." in \
      manuscript_page.get_submission_status_info_text(), \
      manuscript_page.get_submission_status_info_text()
    return self

  def _test_paper_download_buttons(self):
    """
    Placeholder for a function that implement APERTA-45
    """
    # url = self._driver.current_url
    # download_url = '/'.join(url.split('/')[:-1]) + '/download.pdf'
    return self


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
