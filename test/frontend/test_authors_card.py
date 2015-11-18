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
from Pages.manuscript_viewer import ManuscriptViewerPage
from Base.Resources import login_valid_pw, au_login
from frontend.common_test import CommonTest


@MultiBrowserFixture
class AuthorsCardTest(CommonTest):
  """
  Self imposed AC:
     - validate cards elements and styles
     -
  """

  def _go_to_authors_card(self, init=True):
    """Go to the authors card"""
    dashboard = self.login() if init else DashboardPage(self.getDriver())
    article_name = self.select_preexisting_article(init=False)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_card('authors')
    return AuthorsCard(self.getDriver()), article_name

  def test_validate_components(self):
    """Validates styles for the author card and actions"""
    authors_card, title = self._go_to_authors_card()
    header_link = authors_card._get(authors_card._header_link)
    assert header_link.text == title, (header_link.text, title)
    authors_card.validate_styles()
    authors_card.validate_author_card_action()
    authors_card.validate_delete_author()
    authors_card.click_close_button()
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.logout()

    return self


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
