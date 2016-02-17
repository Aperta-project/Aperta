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

import time

@MultiBrowserFixture
class AuthorsTaskTest(CommonTest):
  """
  Self imposed AC:
     - validate tasks elements and styles
     - validate adding and deleting an author
     - validate trying to close a task without completing author profile
  """

  def _go_to_authors_task(self, init=True):
    """Go to the authors task"""
    dashboard = self.login() if init else DashboardPage(self.getDriver())
    article_name = self.create_article(journal="PLOS Wombat", type_="generateCompleteApexData", init=False)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('authors')
    return AuthorsTask(self.getDriver()), article_name

  def test_validate_components(self):
    """Validates styles for the author task"""
    authors_task, title = self._go_to_authors_task()
    authors_task.validate_styles()
    authors_task.validate_author_task_action()
    authors_task.validate_delete_author()
    authors_task.click_completed_checkbox()
    # Attempting to close authors task without a complete author should fail
    # Time for GUI to automatically unselect complete checkbox
    time.sleep(1)
    assert not authors_task.completed_cb_is_selected()
    authors_task.validate_completion_error()
    return self

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
