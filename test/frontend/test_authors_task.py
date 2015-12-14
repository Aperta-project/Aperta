#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Authors Task.
"""
__author__ = 'sbassi@plos.org'

from Base.Decorators import MultiBrowserFixture
from frontend.Tasks.authors_task import AuthorsTask
from Pages.dashboard import DashboardPage
from Pages.manuscript_viewer import ManuscriptViewerPage
from frontend.common_test import CommonTest


@MultiBrowserFixture
class AuthorsTaskTest(CommonTest):
  """
  Self imposed AC:
     - validate cards elements and styles
     -
  """

  def _go_to_authors_task(self, init=True):
    """Go to the authors task"""
    dashboard = self.login() if init else DashboardPage(self.getDriver())
    article_name = self.select_preexisting_article(init=False)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('authors')
    return AuthorsTask(self.getDriver()), article_name

  def test_validate_components(self):
    """Validates styles for the author task"""
    authors_task, title = self._go_to_authors_task()
    header_link = authors_task._get(authors_task._header_link)
    assert header_link.text == title, (header_link.text, title)
    authors_task.validate_styles()
    authors_task.validate_author_task_action()
    authors_task.validate_delete_author()
    authors_task.click_completed_checkbox()
    # Attempting to close authors task without a complete author should fail
    assert not authors_task.completed_cb_is_selected()
    authors_task.validate_completion_error()
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('authors')
    manuscript_page.logout()
    return self

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
