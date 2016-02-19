#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Additional Information Task.
"""
__author__ = 'jgray@plos.org'

import logging
import time

from Base.Decorators import MultiBrowserFixture
from frontend.Tasks.additional_information_task import AITask
from Pages.dashboard import DashboardPage
from Pages.manuscript_viewer import ManuscriptViewerPage
from frontend.common_test import CommonTest


@MultiBrowserFixture
class AddlInfoTaskTest(CommonTest):
  """
  Self imposed AC:
     - validate tasks elements and styles
     - validate closing task
  """
  def _go_to_addl_info_task(self, init=True):
    """Go to the addl info task"""
    dashboard = self.login() if init else DashboardPage(self.getDriver())
    logging.info('Calling Create new Article')
    article_name = self.create_article(journal='PLOS Wombat', type_='generateCompleteApexData')
    manuscript_viewer = ManuscriptViewerPage(self.getDriver())

    manuscript_viewer.click_task('addl_info')
    return AITask(self.getDriver()), article_name

  def test_validate_components(self):
    """Validates styles for the addl_info task"""
    addl_info_task, title = self._go_to_addl_info_task()
    addl_info_task.complete_ai()
    return self

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
