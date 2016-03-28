#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from loremipsum import generate_paragraph

from Base.Decorators import MultiBrowserFixture
from Base.Resources import staff_admin_login, internal_editor_login, pub_svcs_login, \
    super_admin_login, prod_staff_login, creator_login1
from frontend.common_test import CommonTest
from Pages.manuscript_viewer import ManuscriptViewerPage
from selenium.webdriver.common.keys import Keys

"""
This test case validates the Aperta Discussion Forum

XXXXXXX
Note that this case does NOT test actually creating a new manuscript, or accepting or declining an
    invitation

"""
__author__ = 'jgray@plos.org'


staff_users = [staff_admin_login,
         #internal_editor_login,
         #prod_staff_login,
         #pub_svcs_login,
         super_admin_login,
         ]

users = [creator_login1, ]


@MultiBrowserFixture
class DiscussionForumTest(CommonTest):
  """
  Self imposed AC:
     - XXXXXXXXXXXXXX
  """
  def test_notification(self):
    """
    Validates the presence of the following elements:
      Welcome Text, subhead, table presentation
    """
    the_creator = random.choice(users)
    logging.info('Logging in as user: {0}'.format(the_creator))
    dashboard_page = self.cas_login(email=the_creator['email'])
    # Create paper
    dashboard_page.set_timeout(120)
    dashboard_page.click_create_new_submission_button()
    time.sleep(.5)
    paper_type = 'Research'
    logging.info('Creating Article in {0} of type {1}'.format('PLOS Wombat', paper_type))
    self.create_article(title='Testing Discussion Forum notifications',
                        journal='PLOS Wombat',
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
    login_url = self._driver.current_url
    self.invalidate_cas_token()
    self.return_to_login_page(login_url)
    #time.sleep(10)
    user_type = random.choice(staff_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # click on discussion icon
    paper_viewer._get(paper_viewer._discussion_link).click()
    paper_viewer._get(paper_viewer._create_new_topic).click()
    time.sleep(.5)
    paper_viewer._get(paper_viewer._topic_title_field).send_keys(
      'Testing comments in {0}'.format(paper_id))
    # create topic btn
    time.sleep(.5)
    paper_viewer._get(paper_viewer._create_topic).click()
    # add paper creator to the disussion
    #the_creator
    paper_viewer._get(paper_viewer._add_participant_btn).click()
    time.sleep(.5)
    paper_viewer._get(paper_viewer._participant_field).send_keys(
      the_creator['user'] + Keys.ENTER)
    time.sleep(5)
    #import pdb; pdb.set_trace()
    paper_viewer._get(paper_viewer._participant_field).send_keys(Keys.ARROW_DOWN + Keys.ENTER)
    time.sleep(.5)
    #import pdb; pdb.set_trace()
    paper_viewer._get(paper_viewer._message_body_field).send_keys(
      generate_paragraph()[2])
    paper_viewer._get(paper_viewer._post_message_btn).click()
    # send another msg
    paper_viewer.logout()
    login_url = self._driver.current_url
    self.invalidate_cas_token()
    self.return_to_login_page(login_url)
    logging.info('Logging in as user: {0}'.format(the_creator))
    dashboard_page = self.cas_login(email=the_creator['email'])
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # look for icon
    red_badge = paper_viewer._get(paper_viewer._badge_red)
    red_badge_first = int(red_badge.text)
    red_badge.click()
    # look for red icon on workflow page?
    time.sleep(.5)
    paper_viewer._get(paper_viewer._badge_red)
    paper_viewer.logout()
    login_url = self._driver.current_url
    self.invalidate_cas_token()
    self.return_to_login_page(login_url)
    #time.sleep(10)
    user_type = random.choice(staff_users)
    logging.info('Logging in as user: {0}'.format(user_type))
    dashboard_page = self.cas_login(email=user_type['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # click on discussion icon
    paper_viewer._get(paper_viewer._discussion_link).click()
    # click on first discussion
    ###
    paper_viewer._get(paper_viewer._fist_discussion_lnk).click()
    time.sleep(.5)
    paper_viewer._get(paper_viewer._message_body_field).send_keys(
      '@' + the_creator['user'])
    paper_viewer._get(paper_viewer._post_message_btn).click()
    # send another msg
    paper_viewer.logout()
    login_url = self._driver.current_url
    self.invalidate_cas_token()
    self.return_to_login_page(login_url)
    logging.info('Logging in as user: {0}'.format(the_creator))
    dashboard_page = self.cas_login(email=the_creator['email'])
    dashboard_page.go_to_manuscript(paper_id)
    paper_viewer = ManuscriptViewerPage(self.getDriver())
    # look for icon
    red_badge = paper_viewer._get(paper_viewer._badge_red)
    red_badge_last = int(red_badge.text)
    assert red_badge_first + 1 == red_badge_last, (red_badge_first, red_badge_last)
    red_badge.click()
    # look for red icon on workflow page?
    time.sleep(.5)
    paper_viewer._get(paper_viewer._fist_discussion_lnk).click()
    time.sleep(.5)
    red_badge = paper_viewer._get(paper_viewer._comment_sheet_badge_red)
    red_badge_current = int(red_badge.text)
    assert red_badge_first == red_badge_current, (red_badge_first, red_badge_current)



if __name__ == '__main__':
  CommonTest._run_tests_randomly()
