#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.Resources import staff_admin_login, internal_editor_login, pub_svcs_login, \
    super_admin_login, prod_staff_login, creator_login1, creator_login2, \
    creator_login3, creator_login4, creator_login5
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from selenium.webdriver.common.by import By

"""
This test case validates the Aperta Discussion Forum
Automated test case for: add discussion forum notification icons to MS
"""
__author__ = 'sbassi@plos.org'

staff_users = [staff_admin_login, internal_editor_login, prod_staff_login, pub_svcs_login,
               super_admin_login]

users = [creator_login1, creator_login2, creator_login3, creator_login4, creator_login5]

@MultiBrowserFixture
class DiscussionForumTest(CommonTest):
  """
  test_discussion_forum: Add discussion forum notification icons to MS
  AC out of: APERTA-5831
     - When the user is added to a discussion topic
     - When mentioned in a topic
     - Numbered notifications

  """
  def test_notification(self):
    """
    Validates red circle on discussion icon on manuscript, discussion and message topic
    when added to a discussion and when mentioned in a topic.
    Validates display the user's total number of messages with a notification in
    that topic and reset of notifications every time the user click into a discussion
    message.
    """
    creator = random.choice(users)
    journal = 'PLOS Wombat'
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    # Create paper
    dashboard_page.set_timeout(120)
    dashboard_page.click_create_new_submission_button()
    time.sleep(.5)
    paper_type = 'Research'
    logging.info('Creating Article in {0} of type {1}'.format(journal, paper_type))
    self.create_article(title='Testing Discussion Forum notifications',
                        journal=journal,
                        type_=paper_type,
                        random_bit=True,
                        )
    dashboard_page.restore_timeout()
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # check for flash message
    paper_viewer.validate_ihat_conversions_success()
    paper_id = paper_viewer.get_current_url().split('/')[-1]
    paper_id = paper_id.split('?')[0] if '?' in paper_id else paper_id
    logging.info("Assigned paper id: {0}".format(paper_id))
    paper_viewer.logout()
    user_type = random.choice(staff_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    paper_viewer.post_new_discussion(topic='Testing discussion on paper {}'.format(paper_id),
                                     msg='', participants=[creator['user']])
    # send another msg
    paper_viewer.logout()
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # look for icon
    time.sleep(2)
    red_badge = paper_viewer._get(paper_viewer._badge_red)
    red_badge_first = int(red_badge.text)
    red_badge.click()
    time.sleep(.5)
    paper_viewer._get(paper_viewer._badge_red)
    paper_viewer.logout()
    #time.sleep(10)
    user_type = random.choice(staff_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # click on discussion icon
    paper_viewer.post_discussion('@' + creator['user'])
    paper_viewer.logout()
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # look for icon
    red_badge = paper_viewer._get(paper_viewer._badge_red)
    red_badge_last = int(red_badge.text)
    assert red_badge_first + 1 == red_badge_last, (red_badge_first, red_badge_last)
    red_badge.click()
    # look for red icon on workflow page?
    time.sleep(.5)
    paper_viewer._get(paper_viewer._first_discussion_lnk).click()
    time.sleep(.5)
    red_badge = paper_viewer._get(paper_viewer._comment_sheet_badge_red)
    red_badge_current = int(red_badge.text)
    assert red_badge_first == red_badge_current, (red_badge_first, red_badge_current)
    # close and check if any badge
    paper_viewer.close_sheet()
    paper_viewer.set_timeout(2)
    try:
      paper_viewer._get(paper_viewer._badge_red)
      assert False, 'There should not be any discussion badge'
    except ElementDoesNotExistAssertionError:
      logging.info('There is no badge')
    paper_viewer.restore_timeout()

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
