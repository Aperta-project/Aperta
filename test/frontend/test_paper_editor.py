#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the article editor page and its associated ...XXXoverlays.

Note that this case does NOT test actually creating a new manuscript, or accepting or declining an invitation
Those acts are expected to be defined in

"""
__author__ = 'sbassi@plos.org'

import time
import random

from Base.Decorators import MultiBrowserFixture
from Base.FrontEndTest import FrontEndTest
from Pages.login_page import LoginPage
from Base.Resources import login_valid_pw, au_login, rv_login, fm_login, ae_login, he_login, sa_login, oa_login
from Pages.paper_editor import PaperEditorPage

@MultiBrowserFixture
class EditPaperTest(FrontEndTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
         - dashboard page:
            - Optional Invitation elements
              - title, buttons
            - Submissions section
              - title, button, manuscript details
         - view invitations modal dialog elements and function
         - create new submission modal dialog and function
  """
  def test_validate_components_styles(self):
    """
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission
    """
    # Note this is commented out until login with different users
    #user_type = random.choice(users)
    #print('Logging in as user: %s'%user_type)
    #login_page = LoginPage(self.getDriver())
    #login_page.enter_login_field(user_type)
    #login_page.enter_password_field(login_valid_pw)
    #login_page.click_sign_in_button()
    #dashboard_page = DashboardPage(self.getDriver())
    article_title = self._select_preexisting_article()
    paper_editor = PaperEditorPage(self.getDriver())
    paper_editor.validate_page_elements_styles_functions()


    time.sleep(1)
    return self

  def _test_paper_download_buttons(self):
    """
    Placeholder for a function that implement APERTA-45
    """
    # url = self._driver.current_url
    # download_url = '/'.join(url.split('/')[:-1]) + '/download.pdf'

    return self



if __name__ == '__main__':
  FrontEndTest._run_tests_randomly()
