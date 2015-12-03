#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the article editor page and its associated overlays.
"""
__author__ = 'sbassi@plos.org'

import time
import random
import os

from Base.Decorators import MultiBrowserFixture
from Base.CustomException import ElementDoesNotExistAssertionError
from Pages.login_page import LoginPage
from Base.Resources import login_valid_pw, au_login, rv_login, fm_login, ae_login, he_login, sa_login, oa_login
from Base.PostgreSQL import PgSQL
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.dashboard import DashboardPage
from frontend.common_test import CommonTest, docs

users = (au_login, rv_login, ae_login, he_login, sa_login, oa_login)

@MultiBrowserFixture
class EditPaperTest(CommonTest):
  """
  AC from Aperta-3:
     - validate page elements and styles
     - Validate different role aware menu items

  AC from Aperta-5515:
     - When the page is opened for first time, check for info box.
     - Test closing the info box
     - Info box appears for initial manuscript view only, whether the user closes or leaves it open
     - Info box does not appear for Collaborators
  """

  def _test_validate_components_styles(self):
    """
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
    article_title = self.select_preexisting_article()
    manuscript_viewer = ManuscriptViewerPage(self.getDriver())
    manuscript_viewer.validate_page_elements_styles_functions()
    return self

  def _test_role_aware_menus(self):
    """
    Validates role aware menus
    """
    roles = {au_login: 7,
             rv_login: 7,
             ae_login: 7,
             he_login: 8,
             sa_login: 8,
             oa_login: 8}

    for user in users:
      print('Logging in as user: {}'.format(user))
      print('role: {}'.format(roles[user]))

      uid = PgSQL().query('SELECT id FROM users where username = %s;', (user,))[0][0]
      login_page = LoginPage(self.getDriver())
      login_page.enter_login_field(user)
      login_page.enter_password_field(login_valid_pw)
      login_page.click_sign_in_button()
      # the following call should only succeed for sa_login
      dashboard_page = DashboardPage(self.getDriver())
      if dashboard_page.validate_manuscript_section_main_title(user) > 0:
        self.select_preexisting_article(init=False, first=True)
        manuscript_viewer = ManuscriptViewerPage(self.getDriver())
        time.sleep(3) # needed to give time to retrieve new menu items
        if user == ae_login:
          paper_id = manuscript_viewer.get_paper_db_id()
          permissions = PgSQL().query('SELECT paper_roles.role FROM paper_roles '
                              'where user_id = %s and paper_id = %s;',
                              (uid, paper_id)
                              )
          for x in permissions:
            if ('editor',) == x:
              roles[user] = 8
        manuscript_viewer.validate_roles(roles[user])
        url = self._driver.current_url
        signout_url = url[:url.index('/papers/')] + '/users/sign_out'
      else:
        print('No manuscripts present for user: %s' % user)
        # Logout
        url = self._driver.current_url
        signout_url = url + '/users/sign_out'
      self._driver.get(signout_url)
    return self

  def test_infobox(self):
    """
    Aperta-5515
    """
    print('Logging in as user: {}'.format(au_login))
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(au_login)
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()
    # the following call should only succeed for sa_login
    dashboard_page = DashboardPage(self.getDriver())
    # create a new manuscript
    dashboard_page.click_create_new_submission_button()
    # We recently became slow drawing this overlay (20151006)
    time.sleep(.5)
    title = dashboard_page.title_generator()
    dashboard_page.enter_title_field(title)
    dashboard_page.select_journal_and_type('PLOS Wombat', 'Images+InitialDecision')
    doc2upload = random.choice(docs)
    fn = os.path.join(os.getcwd(), 'frontend/assets/docs/', doc2upload)
    if os.path.isfile(fn):
      self._driver.find_element_by_id('upload-files').send_keys(fn)
    else:
      raise IOError('Docx file not found: {}'.format(fn))
    dashboard_page.click_upload_button()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # Note: Request title to make sure the required page is loaded
    manuscript_page.get_paper_title_from_page()
    paper_url = manuscript_page.get_current_url()
    print('The paper ID of this newly created paper is: ' + paper_url)
    paper_id = paper_url.split('papers/')[1]
    # AC1 Test for info box
    infobox = manuscript_page.get_infobox()
    # AC2 Test closing the infobox
    infobox.find_element_by_id('sp-close').click()
    time.sleep(.5)
    manuscript_page.set_timeout(.5)
    try:
      manuscript_page.get_infobox()
    except ElementDoesNotExistAssertionError:
      assert True
    else:
      assert False, "Infobox still open. AC2 fails"
    manuscript_page.restore_timeout()
    # AC3 Green info box appears for initial manuscript view only - whether the user closes or leaves it open
    # go to dashboard
    manuscript_page.click_dashboard_link()
    self._driver.get(paper_url)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    # Note: Request title to make sure the required page is loaded
    manuscript_page.get_paper_title_from_page()
    manuscript_page.set_timeout(.5)
    try:
      manuscript_page.get_infobox()
    except ElementDoesNotExistAssertionError:
      assert True
    else:
      assert False, "Infobox still open. AC3 fails"
    manuscript_page.restore_timeout()
    # AC4 Green info box does not appear for Collaborators
    url = self._driver.current_url
    signout_url = url + '/users/sign_out'
    self._driver.get(signout_url)



    time.sleep(15)
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
