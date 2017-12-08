#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This test case validates the Authors Task.
"""

import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import users
from frontend.Tasks.authors_task import AuthorsTask
from .Pages.manuscript_viewer import ManuscriptViewerPage
from frontend.common_test import CommonTest

__author__ = 'sbassi@plos.org'


@MultiBrowserFixture
class AuthorsTaskTest(CommonTest):
  """
  Self imposed AC:
     - validate tasks elements and styles
     - validate adding and deleting an author
     - validate trying to close a task without completing author profile
  """

  def test_smoke_validate_components_styles(self):
    """
    test_smoke_validate_components_styles: Validates the elements, styles and functions for the
      author task
    :return: void function
    """
    logging.info('Test Authors Task::components_styles')
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    self.create_article(title='Testing Authors Task', journal='PLOS Wombat', type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.click_task('Authors')
    authors_task = AuthorsTask(self.getDriver())
    authors_task.validate_styles()

  def test_core_add_delete_individual_author(self):
    """
    test_core_add_delete_individual_author: Validates add and delete individual author functions
      for the author task
    :return: void function
    """
    logging.info('Test Authors Task::add_delete_individual_author')
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    self.create_article(title='Testing Authors Task - delete author', journal='PLOS Wombat',
                        type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.click_task('Authors')
    authors_task = AuthorsTask(self.getDriver())
    authors_task.add_individual_author_task_action()
    authors_task.validate_delete_author()
    # The author task is large enough that the Completion button frequently scrolls to an a place
    #   place obscured by the task title. This two step boogaloo resets the view to the top of the
    #   task.
    manuscript_page.click_task('Authors')
    manuscript_page.click_task('Authors')
    authors_task = AuthorsTask(self.getDriver())
    time.sleep(3)
    authors_task.click_completion_button()
    # Attempting to close authors task without a complete author or acknowledgements should fail
    # Time for GUI to automatically deselect complete checkbox
    time.sleep(1)
    assert not authors_task.completed_state()
    # We expect a completion error to to fire because several required elements are not complete.
    # The metadata versioning test case covers the everything completely filled out case.
    authors_task.validate_completion_error()
    return self

  def test_core_add_delete_group_author(self):
    """
    test_core_add_delete_group_author: Validates add and delete group author functions for the
      author task
    :return: void function
    """
    logging.info('Test Authors Task::test_core_add_delete_group_author')
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    self.create_article('Testing Authors Task - delete group author', journal='PLOS Wombat',
                        type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.click_task('Authors')
    authors_task = AuthorsTask(self.getDriver())
    authors_task.add_group_author_task_action()
    authors_task.validate_delete_author()
    return self

  def test_author_editing(self):
    """
        test_author_editing: Validates editing the current author
        :return: void function
        """
    logging.info('Test Authors Task::test_author_editing')
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    self.create_article('Testing Authors Task - author editing', journal='PLOS Wombat',
                        type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    manuscript_page.click_task('Authors')
    authors_task = AuthorsTask(self.getDriver())
    authors_task.edit_author(user_type)

if __name__ == '__main__':
  CommonTest.run_tests_randomly()
