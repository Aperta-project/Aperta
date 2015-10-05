#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates metadata versioning for Aperta.
"""
__author__ = 'sbassi@plos.org'

import time

from Base.Decorators import MultiBrowserFixture
from Pages.dashboard import DashboardPage
from Cards.basecard import BaseCard
from Pages.paper_editor import PaperEditorPage
from frontend.common_test import CommonTest

@MultiBrowserFixture
class MetadataVersioningTest(CommonTest):
  """
  Self imposed AC:
     -
  """
  def test_metadata_versioning(self):
    """
    """
    title = 'Metadata Versioning'
    #if True: # for debugging
    if self.check_article(title):
      init = True if 'users/sign_in' in self._driver.current_url else False
      article = self.select_preexisting_article(title=title, init=init)
    else:
      # Create new article
      title = self.create_article(title='Metadata Versioning',
                                 journal='PLOS Wombat',
                                 type_='Research',
                                 random_bit=True,
                                 init=False)
    paper_editor = PaperEditorPage(self.getDriver())
    paper_editor.complete_card('Billing')
    paper_editor.complete_card('Authors')
    paper_editor.complete_card('Cover Letter')
    paper_editor.complete_card('Figures')
    paper_editor.complete_card('Supporting Info')
    paper_editor.complete_card('Upload Manuscript')
    # Click submit
    paper_editor.press_submit_btn()
    paper_editor.confirm_submit_btn()

    time.sleep(5)
    return self


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
