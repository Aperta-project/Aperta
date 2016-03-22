#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import staff_admin_login, super_admin_login, creator_login1, creator_login2, \
    creator_login3, creator_login4, creator_login5, reviewer_login, academic_editor_login, \
    handling_editor_login, internal_editor_login, pub_svcs_login
from frontend.Tasks.authors_task import AuthorsTask
from Pages.manuscript_viewer import ManuscriptViewerPage
from frontend.common_test import CommonTest

"""
This test case validates the Authors Task.
"""
__author__ = 'sbassi@plos.org'

users = [creator_login1,
         creator_login2,
         creator_login3,
         creator_login4,
         creator_login5,
         reviewer_login,
         handling_editor_login,
         academic_editor_login,
         internal_editor_login,
         staff_admin_login,
         pub_svcs_login,
         super_admin_login,
         ]


@MultiBrowserFixture
class AuthorsTaskTest(CommonTest):
  """
  Self imposed AC:
     - validate tasks elements and styles
     - validate adding and deleting an author
     - validate trying to close a task without completing author profile
  """

  def test_validate_components(self):
    """
    test_authors_task: Validates the elements, styles and functions for the author task
    :return: void function
    """
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    # self.create_article(journal='PLOS Wombat', type_='Research',)
    self.create_article(journal='PLOS Yeti', type_='Research',)
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(10)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('authors')
    authors_task = AuthorsTask(self.getDriver())
    authors_task.validate_styles()

  def test_validate_add_delete_individual_author(self):
    """
    test_authors_task: Validates add and delete individual author functions for the author task
    :return: void function
    """
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    # self.create_article(journal='PLOS Wombat', type_='Research',)
    self.create_article(journal='PLOS Yeti', type_='Research',)
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(10)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('authors')
    authors_task = AuthorsTask(self.getDriver())
    authors_task.add_individual_author_task_action()
    authors_task.validate_delete_author()
    # The author task is large enough that the Completion button frequently scrolls to an a place
    #   place obscured by the task title. This two step boogaloo resets the view to the top of the
    #   task.
    manuscript_page.click_task('authors')
    manuscript_page.click_task('authors')
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

  def test_validate_add_delete_group_author(self):
    """
    test_authors_task: Validates add and delete group author functions for the author task
    :return: void function
    """
    user_type = random.choice(users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard = self.cas_login(user_type['email'])
    dashboard.click_create_new_submission_button()
    # self.create_article(journal='PLOS Wombat', type_='Research',)
    self.create_article(journal='PLOS Yeti', type_='Research',)
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(10)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.click_task('authors')
    authors_task = AuthorsTask(self.getDriver())
    authors_task.add_group_author_task_action()
    authors_task.validate_delete_author()
    return self

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
