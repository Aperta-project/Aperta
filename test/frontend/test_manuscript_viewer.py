#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Resources import login_valid_pw, creator_login1, creator_login2, creator_login3, \
    creator_login4, creator_login5, reviewer_login, handling_editor_login, academic_editor_login, \
    internal_editor_login, cover_editor_login, staff_admin_login, pub_svcs_login, \
    prod_staff_login, super_admin_login
from Base.PostgreSQL import PgSQL
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage
from Cards.initial_decision_card import InitialDecisionCard
from frontend.common_test import CommonTest

"""
This test case validates the article editor page and its associated overlays.
"""
__author__ = 'sbassi@plos.org'

users = [creator_login1,
         creator_login2,
         creator_login3,
         creator_login4,
         creator_login5,
         reviewer_login,
         handling_editor_login,
         cover_editor_login,
         academic_editor_login,
         internal_editor_login,
         staff_admin_login,
         pub_svcs_login,
         prod_staff_login,
         super_admin_login,
         ]


@MultiBrowserFixture
class ViewPaperTest(CommonTest):
  """
  This class implements:
    APERTA-5515
    APERTA-3
  """

  def test_validate_components_styles(self):
    """
    test_manuscript_viewer: Validate elements and styles for the manuscript viewer page
    APERTA-3: validate page elements and styles
    Validates the presence of the following elements:
      - icons in text area (editor menu)
      - button for comparing versions
      - button for adding collaborators
      - button for paper download
      - button for recent activity
      - button for discussions
      - button for workflow
      - button for more options
    """
    user = random.choice(users)
    logging.info('Running test_validate_components_styles')
    logging.info('Logging in as {0}'.format(user))
    dashboard_page = self.cas_login(email=user['email'])
    # Checking if there is already a manuscript one can use
    if dashboard_page.validate_manuscript_section_main_title(user)[0]:
      self.select_preexisting_article(first=True)
    else:
      # create a new manuscript
      dashboard_page.click_create_new_submission_button()
      # We recently became slow drawing this overlay (20151006)
      time.sleep(.5)
      # Temporary changing timeout
      dashboard_page.set_timeout(120)
      self.create_article(journal='PLOS Wombat',
                          type_='Images+InitialDecision',
                          random_bit=True,
                          )
      # Time needed for iHat conversion. This is not quite enough time in all circumstances
      time.sleep(5)
    manuscript_viewer = ManuscriptViewerPage(self.getDriver())
    manuscript_viewer.validate_nav_toolbar_elements(user)
    if user in (staff_admin_login, super_admin_login):
      manuscript_viewer.validate_page_elements_styles_functions(useremail=user['email'],
                                                                admin=True)
    else:
      manuscript_viewer.validate_page_elements_styles_functions(useremail=user['email'],
                                                                admin=False)
    return self

  def _test_role_aware_menus(self):
    """
    APERTA-3: Validates role aware menus
    """
    roles = {creator_login1['email']: 7,
             creator_login2['email']: 7,
             creator_login3['email']: 7,
             creator_login4['email']: 7,
             creator_login5['email']: 7,
             reviewer_login['email']: 7,
             academic_editor_login['email']: 7,
             handling_editor_login['email']: 8,
             super_admin_login['email']: 8,
             staff_admin_login['email']: 8,
             pub_svcs_login['email']: 7,
             internal_editor_login['email']: 8,
             }

    for user in users:
      logging.info('Logging in as user: {0}'.format(user))
      logging.info('role: {0}'.format(roles[user['user']]))
      uid = PgSQL().query('SELECT id FROM users where username = %s;', (user['user'],))[0][0]
      dashboard_page = self.cas_login(user['email'])
      dashboard_page.set_timeout(120)
      if dashboard_page.validate_manuscript_section_main_title(user['user']) > 0:
        dashboard_page.restore_timeout()
        self.select_preexisting_article(init=False, first=True)
        manuscript_viewer = ManuscriptViewerPage(self.getDriver())
        time.sleep(3)  # needed to give time to retrieve new menu items
        if user['user'] == academic_editor_login['user']:
          paper_id = manuscript_viewer.get_paper_db_id()
          permissions = PgSQL().query('SELECT paper_roles.old_role FROM paper_roles '
                                      'WHERE user_id = %s AND paper_id = %s;', (uid, paper_id))
          for x in permissions:
            if ('editor',) == x:
              roles[user['user']] = 8
        manuscript_viewer.validate_roles(roles[user['user']])
      else:
        dashboard_page.restore_timeout()
        logging.info('No manuscripts present for user: {0}'.format(user['user']))
    # Logout
    dashboard_page.logout()
    return self

  def test_initial_submission_infobox(self):
    """
    test_manuscript_viewer: Validate elements and styles of the initial submission infobox
    Aperta-5515

    AC from Aperta-5515:
      1. When the page is opened for first time, check for info box.
      2. Test closing the info box
      3. Info box appears for initial manuscript view only, whether the user closes or leaves it
          open
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
    logging.info('Logging in as user: {0}'.format(creator_login5))
    dashboard_page = self.cas_login(email=creator_login5['email'])
    # create a new manuscript
    dashboard_page.click_create_new_submission_button()
    # We recently became slow drawing this overlay (20151006)
    time.sleep(.5)
    # Temporary changing timeout
    dashboard_page.set_timeout(120)
    self.create_article(journal='PLOS Wombat',
                        type_='Images+InitialDecision',
                        random_bit=True,
                        )
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # AC1 Test for info box
    infobox = manuscript_page.get_infobox()
    dashboard_page.restore_timeout()
    # Note: Request title to make sure the required page is loaded
    paper_url = manuscript_page.get_current_url()
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_url))

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
    # AC3 Green info box appears for initial manuscript view only - whether the user closes or
    #   leaves it open
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

    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # Add a collaborator (for AC4)
    # APERTA-6840 - we disabled add collaborators temporarily
    # manuscript_page.add_collaborators(creator_login4)
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
    # APERTA-6840 - we disabled add collaborators temporarily
    # manuscript_page.logout()


    # dashboard_page = self.cas_login(email=creator_login4['email'], password=login_valid_pw)
    # dashboard_page.go_to_manuscript(paper_id)
    # time.sleep(1)
    # manuscript_page = ManuscriptViewerPage(self.getDriver())
    # manuscript_page.set_timeout(.5)
    # # AC4 Green info box does not appear for collaborators
    # try:
    #   manuscript_page.get_infobox()
    # except ElementDoesNotExistAssertionError:
    #   assert True
    # else:
    #   assert False, "Infobox still open. AC4 fails"
    # manuscript_page.restore_timeout()
    # Submit
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    manuscript_page.close_modal()
    manuscript_page.logout()

    # Approve initial Decision
    logging.info('Logging in as user: {0}'.format(super_admin_login['user']))
    dashboard_page = self.cas_login(email=super_admin_login['email'], password=login_valid_pw)
    time.sleep(1)
    # the following call should only succeed for superadm
    dashboard_page.go_to_manuscript(paper_id)
    time.sleep(1)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.click_card('initial_decision')
    initial_decision_card = InitialDecisionCard(self.getDriver())
    initial_decision_card.execute_decision('invite')
    time.sleep(5)
    manuscript_page.logout()

    # Test for AC8
    logging.info('Logging in as user: {0}'.format(creator_login5))
    dashboard_page = self.cas_login(email=creator_login5['email'])
    time.sleep(1)
    # the following call should only succeed for sa_login
    dashboard_page.go_to_manuscript(paper_id)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # AC8: Message for full submission when is ready for submition
    manuscript_page._get(manuscript_page._nav_aperta_dashboard_link)
    time.sleep(5)
    assert 'Your manuscript is ready for Full Submission.' in \
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
