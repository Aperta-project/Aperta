#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the article editor page and its associated overlays.
"""
__author__ = 'sbassi@plos.org'

import time

from Base.Decorators import MultiBrowserFixture
from Pages.login_page import LoginPage
from Base.Resources import login_valid_pw, au_login, rv_login, fm_login, ae_login, he_login, sa_login, oa_login
from Base.PostgreSQL import PgSQL
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.dashboard import DashboardPage
from frontend.common_test import CommonTest

users = (au_login, rv_login, ae_login, he_login, sa_login, oa_login)

@MultiBrowserFixture
class EditPaperTest(CommonTest):
  """
  AC from Aperta-3:
     - validate page elements and styles
     - Validate different role aware menu items
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

  def test_role_aware_menus(self):
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

      # get current journal_id

      #journal_ids = PgSQL().query('SELECT roles.journal_id FROM roles INNER JOIN user_roles '
        #                          'ON roles.id = user_roles.role_id '
        #                          'WHERE user_roles.user_id = %s '
        #                          'AND roles.kind IN %s;', (uid, ('flow manager', 'admin', 'editor')))

      login_page = LoginPage(self.getDriver())
      login_page.enter_login_field(user)
      login_page.enter_password_field(login_valid_pw)
      login_page.click_sign_in_button()
      # the following call should only succeed for sa_login
      dashboard_page = DashboardPage(self.getDriver())
      if dashboard_page.validate_manuscript_section_main_title(user) > 0:
        self.select_preexisting_article(init=False, first=True)
        manuscript_viewer = ManuscriptViewerPage(self.getDriver())
        time.sleep(1)
        paper_id = manuscript_viewer.get_paper_db_id()
        print PgSQL().query('SELECT paper_roles.role FROM paper_roles where user_id = %s and paper_id = %s;', (uid, paper_id))

        #journal_id = manuscript_viewer.get_journal_id()


        time.sleep(3) # needed to give time to retrieve new menu items
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


  def _test_paper_download_buttons(self):
    """
    Placeholder for a function that implement APERTA-45
    """
    # url = self._driver.current_url
    # download_url = '/'.join(url.split('/')[:-1]) + '/download.pdf'
    return self


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
