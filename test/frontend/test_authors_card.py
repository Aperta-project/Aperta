#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Authors Card.
"""
__author__ = 'sbassi@plos.org'

import random
import time

from Base.Decorators import MultiBrowserFixture
from frontend.Cards.authors_card import AuthorsCard
from Pages.login_page import LoginPage
from Pages.dashboard import DashboardPage
from Pages.manuscript_page import ManuscriptPage
from Base.Resources import login_valid_pw, au_login
from frontend.common_test import CommonTest


@MultiBrowserFixture
class AuthorsCardTest(CommonTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
  """

  def _go_to_authors_card(self, init=True):
    """Go to the authors card"""
    dashboard = LoginPage.login() if init else DashboardPage(self.getDriver())
    article_name = LoginPage.select_preexisting_article(init=False)
    manuscript_page = ManuscriptPage(self.getDriver())
    manuscript_page.click_authors_card()
    return AuthorsCard(self.getDriver()), article_name

  def test_validate_components_styles(self):
    """
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission
    """
    authors_card, title = self._go_to_authors_card()
    header_link = authors_card._get(authors_card._header_link)
    assert header_link.text == title, (header_link.text, title)
    authors_card.validate_styles()
    time.sleep(2)
    return self


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
