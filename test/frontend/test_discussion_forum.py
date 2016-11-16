#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random
import time

from loremipsum import generate_paragraph
from dateutil import tz

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import users, editorial_users, admin_users
from frontend.common_test import CommonTest
from Cards.invite_reviewer_card import InviteReviewersCard
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

"""
This test case validates the Aperta Discussion Forum
Automated test case for: add discussion forum notification icons to MS
"""
__author__ = 'sbassi@plos.org'

staff_users = admin_users + editorial_users

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
    logging.info('Test Discussion Forum::notification')
    web_page = random.choice(['manuscript viewer', 'workflow'])
    logging.info('Test discussion on: {0}'.format(web_page))
    current_path = os.getcwd()
    logging.info(current_path)
    creator = random.choice(users)
    journal = 'PLOS Wombat'
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    # Create paper
    dashboard_page.set_timeout(120)
    dashboard_page.click_create_new_submission_button()
    time.sleep(.5)
    paper_type = 'OnlyInitialDecisionCard'
    logging.info('Creating Article in {0} of type {1}'.format(journal, paper_type))
    self.create_article(title='Testing Discussion Forum notifications', journal=journal,
                        type_=paper_type, random_bit=True)
    dashboard_page.restore_timeout()
    ms_viewer = ManuscriptViewerPage(self.getDriver())
    # check for flash message
    ms_viewer.validate_ihat_conversions_success(timeout=45)
    logging.info(ms_viewer.get_current_url())
    paper_id = ms_viewer.get_paper_id_from_url()
    counter = 0
    while not paper_id:
      time.sleep(1)
      paper_id = ms_viewer.get_paper_id_from_url()
      counter += 1
      if counter >= 60:
        raise  ValueError('Page not loaded')
    logging.info(u'Assigned paper id: {0}'.format(paper_id))
    ms_viewer.logout()
    staff_user = random.choice(staff_users)
    logging.info(u'Logging in as user: {0}'.format(staff_user))
    dashboard_page = self.cas_login(email=staff_user['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    ms_viewer = ManuscriptViewerPage(self.getDriver())
    if web_page == 'manuscript viewer':
      # This is failing for Asian Character set usernames of only two characters APERTA-7862
      ms_viewer.post_new_discussion(topic='Testing discussion on paper {}'.format(paper_id),
                                  participants=[creator])
    elif web_page == 'workflow':
      ms_viewer.click_workflow_link()
      workflow_page = WorkflowPage(self.getDriver())
      workflow_page.page_ready()
      workflow_page.post_new_discussion(topic='Testing discussion on paper {}'.format(paper_id),
                                        participants=[creator])
    ms_viewer.logout()

    logging.info(u'Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.go_to_manuscript(paper_id)
    ms_viewer = ManuscriptViewerPage(self.getDriver())
    # look for icon
    time.sleep(2)
    ms_viewer.set_timeout(120)
    red_badge = ms_viewer._get(ms_viewer._badge_red)
    ms_viewer.restore_timeout()
    red_badge_first = int(red_badge.text)
    red_badge.click()
    time.sleep(.5)
    ms_viewer._get(ms_viewer._badge_red)
    ms_viewer.logout()

    logging.info(u'Logging in as user: {0}'.format(staff_user))
    dashboard_page = self.cas_login(email=staff_user['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    ms_viewer = ManuscriptViewerPage(self.getDriver())
    # click on discussion icon
    ms_viewer.click_discussion_link()
    ms_viewer.post_discussion('@' + creator['user'])
    ms_viewer.logout()
    logging.info(u'Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    dashboard_page.go_to_manuscript(paper_id)
    ms_viewer = ManuscriptViewerPage(self.getDriver())
    # look for icon
    time.sleep(2)
    red_badge = ms_viewer._get(ms_viewer._badge_red)
    red_badge_last = int(red_badge.text)
    assert red_badge_first + 1 == red_badge_last, '{0} is different from {1}. This may be '\
        'caused by APERTA-8303'.format(red_badge_first + 1, red_badge_last)
    red_badge.click()
    # look for red icon on workflow page?
    time.sleep(.5)
    ms_viewer._get(ms_viewer._first_discussion_lnk).click()
    time.sleep(.5)
    red_badge = ms_viewer._get(ms_viewer._comment_sheet_badge_red)
    red_badge_current = int(red_badge.text)
    assert red_badge_first == red_badge_current, '{0} is different from {1}'.format(
        red_badge_first, red_badge_last)
    # close and check if any badge
    ms_viewer.close_sheet()
    ms_viewer.set_timeout(2)
    try:
      ms_viewer._get(ms_viewer._badge_red)
      assert False, 'There should not be any discussion badge'
    except ElementDoesNotExistAssertionError:
      logging.info('There is no badge')
    ms_viewer.restore_timeout()

  def test_discussion_ms_viewer(self):
    """
    This test validates a dicussion from the manuscript view. It involves multiple
    participants, an admin user post a discussion and adds two particpiants. These
    participants are invited as reviewers.
    The reviewers accepts the role and checks for messages, one reviewer make a post
    mentioning the other reviewer and this mention should be highlighted.
    All participants checks for content, user and time.
    """
    web_page = random.choice(['manuscript viewer', 'workflow'])
    logging.info('Test discussion on: {0}'.format(web_page))
    creator, collaborator_1, collaborator_2 = random.sample(users, 3)
    logging.info('Collaborator 1: {0}'.format(collaborator_1))
    logging.info('Collaborator 2: {0}'.format(collaborator_2))
    journal = 'PLOS Wombat'
    logging.info('Logging in as user: {0}'.format(creator))
    dashboard_page = self.cas_login(email=creator['email'])
    # Create paper
    dashboard_page.set_timeout(120)
    dashboard_page.click_create_new_submission_button()
    time.sleep(.5)
    paper_type = 'NoCards'
    logging.info('Creating Article in {0} of type {1}'.format(journal, paper_type))
    self.create_article(title='Testing Discussion Forum',
                        journal=journal,
                        type_=paper_type,
                        random_bit=True,
                        )
    dashboard_page.restore_timeout()
    ms_viewer = ManuscriptViewerPage(self.getDriver())
    ms_viewer.validate_ihat_conversions_success(timeout=45)
    logging.info(ms_viewer.get_current_url())
    paper_id = ms_viewer.get_paper_id_from_url()
    counter = 0
    while not paper_id:
      time.sleep(1)
      paper_id = ms_viewer.get_paper_id_from_url()
      counter += 1
      if counter >= 60:
        raise  ValueError('Page not loaded')
    logging.info(u'Assigned paper id: {0}'.format(paper_id))
    # Submit paper
    # reviewer1
    ms_viewer.click_submit_btn()
    ms_viewer.confirm_submit_btn()
    ms_viewer.close_modal()
    # Creator logout
    ms_viewer.logout()

    # Once the paper is created, add collaborator
    user_id = PgSQL().query('SELECT id FROM users where username = %s;',
        (collaborator_1['user'],))[0][0]
    journal_id = PgSQL().query('SELECT journal_id FROM papers where id = %s;',
        (paper_id,))[0][0]
    role_id = PgSQL().query('SELECT id FROM roles where journal_id = %s '
        'AND name = %s;', (journal_id, 'Collaborator'))[0][0]
    # Add collaborator
    PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, '
                   'assigned_to_type, created_at, updated_at) VALUES (%s, %s, %s, \'Paper\','
                   ' now(), now());', (user_id, role_id, paper_id))
    user_id = PgSQL().query('SELECT id FROM users where username = %s;',
        (collaborator_2['user'],))[0][0]
    PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, '
                   'assigned_to_type, created_at, updated_at) VALUES (%s, %s, %s, \'Paper\','
                   ' now(), now());', (user_id, role_id, paper_id))

    # Login as Staff user
    # This will fail when superadmin is chosen due to a app bug
    staff_user = random.choice(staff_users)
    logging.info(u'Logging in as user: {0}'.format(staff_user))
    dashboard_page = self.cas_login(email=staff_user['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    ms_viewer = ManuscriptViewerPage(self.getDriver())
    ms_viewer._wait_for_element(ms_viewer._get(ms_viewer._tb_workflow_link))
    msg_1 = generate_paragraph()[2]
    # This is failing for Asian Character set usernames of only two characters APERTA-7862
    topic = 'Testing discussion on paper {0}'.format(paper_id)
    # How to call the discussion section
    if web_page == 'workflow':
      ms_viewer.post_new_discussion(topic=topic, msg=msg_1,
        participants=[collaborator_1, collaborator_2])
    elif web_page == 'manuscript viewer':
      dashboard_page.go_to_manuscript(paper_id)
      ms_viewer = ManuscriptViewerPage(self.getDriver())
      # Add R1 y R2
      ms_viewer._wait_for_element(ms_viewer._get(ms_viewer._tb_workflow_link))
      ms_viewer.post_new_discussion(topic=topic, msg=msg_1,
        participants=[collaborator_1, collaborator_2])
    # Staff user logout
    ms_viewer.logout()

    # Collaborator 1
    logging.info(u'Logging in as user Collaborator 1: {}'.format(collaborator_1))
    dashboard_page = self.cas_login(email=collaborator_1['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    ms_viewer = ManuscriptViewerPage(self.getDriver())
    ms_viewer._wait_for_element(ms_viewer._get(ms_viewer._discussion_link))
    ms_viewer.click_discussion_link()
    discussion_link = ms_viewer._get(ms_viewer._first_discussion_lnk)
    discussion_title = discussion_link.text
    assert topic in discussion_title, '{0} not in {1}'.format(topic, discussion_title)
    discussion_link.click()
    created, discussion_topic_id = PgSQL().query(
      'SELECT created_at, id FROM discussion_topics WHERE paper_id = %s;',
      (paper_id,))[0]
    from_zone = tz.gettz('UTC')
    to_zone = tz.tzlocal()
    created = created.replace(tzinfo=from_zone)
    db_time = created.astimezone(to_zone)
    # Note: %-d removes leading 0 only in Unix. If this suite ever going to be running
    # in Windows, we should detect OS and pass an alternative solution.
    db_time_fe_format = db_time.strftime('%B %-d, %Y %H:%M')
    comment_name = ms_viewer._get(ms_viewer._comment_name).text
    comment_date = ms_viewer._get(ms_viewer._comment_date).text
    header_fe = u'{0} {1}'.format(comment_name, comment_date)
    header_db = u'{0} posted {1}'.format(staff_user['name'], db_time_fe_format)
    assert header_fe == header_db, 'Header from the front end: {0} not the same as '\
        'in DB: {1}'.format(header_fe, header_db)
    comment_body = ms_viewer._get(ms_viewer._comment_body).text
    assert msg_1 == comment_body, 'Message sent: {0} not the message found in the '\
         'front end: {1}'.format(msg_1, comment_body)
    msg_2 = generate_paragraph()[2]
    discussion_back_link = ms_viewer._get(ms_viewer._discussion_back_link)
    discussion_back_link.click()
    ms_viewer.post_discussion(msg_2, mention=collaborator_2['user'])
    # Time needed for the new discussion to appear after AJAX call
    time.sleep(2)
    # Look for the mention and check style    
    mention = ms_viewer.get_mention(collaborator_2['user'])
    assert mention, 'Mention {0} is not present in the post'.format(collaborator_2['user'])
    ms_viewer.validate_mention_style(mention)
    ms_viewer.logout()

    # Collaborator 2
    logging.info(u'Logging in as user Collaborator 2: {0}'.format(collaborator_2))
    dashboard_page = self.cas_login(email=collaborator_2['email'])
    dashboard_page.click_view_invitations()
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    ms_viewer = ManuscriptViewerPage(self.getDriver())
    ms_viewer._wait_for_element(ms_viewer._get(ms_viewer._discussion_link))
    ms_viewer.click_discussion_link()
    discussion_link = ms_viewer._get(ms_viewer._first_discussion_lnk)
    discussion_title = discussion_link.text
    assert topic in discussion_title, '{0} not in {1}'.format(topic, discussion_title)
    discussion_link.click()
    created = PgSQL().query('SELECT created_at FROM discussion_replies WHERE '
      'discussion_topic_id = %s;', (discussion_topic_id,))[0][0]
    from_zone = tz.gettz('UTC')
    to_zone = tz.tzlocal()
    created = created.replace(tzinfo=from_zone)
    db_time = created.astimezone(to_zone)
    # Note: %-d removes leading 0 only in Unix. If this suite ever going to be running
    # in Windows, we should detect OS and pass an alternative solution.
    db_time_fe_format = db_time.strftime('%B %-d, %Y %H:%M')
    comment_name = ms_viewer._get(ms_viewer._comment_name).text
    comment_date = ms_viewer._get(ms_viewer._comment_date).text
    header_fe = u'{0} {1}'.format(comment_name, comment_date)
    header_db = u'{0} posted {1}'.format(collaborator_1['name'], db_time_fe_format)
    assert header_fe == header_db, 'Header from front end: {0}, is not the same as '\
        'header from the DB: {1}'.format(header_fe, header_db)
    comment_body = ms_viewer._get(ms_viewer._comment_body).text
    assert msg_2 in comment_body, 'Message sent: {0} is not in the front end {1}'\
        .format(msg_2, comment_body)
    ms_viewer.logout()

    # Login as Staff user
    logging.info(u'Logging in as user: {0}'.format(staff_user))
    dashboard_page = self.cas_login(email=staff_user['email'])
    # go to article id paper_id
    dashboard_page.go_to_manuscript(paper_id)
    ms_viewer = ManuscriptViewerPage(self.getDriver())
    ms_viewer._wait_for_element(ms_viewer._get(ms_viewer._discussion_link))
    ms_viewer.click_discussion_link()
    try:
      discussion_link = ms_viewer._get(ms_viewer._first_discussion_lnk)
    except ElementDoesNotExistAssertionError:
      raise(ElementDoesNotExistAssertionError, 'This may be caused by APERTA-7902')
    discussion_title = discussion_link.text
    assert topic in discussion_title, 'Sent topic: {0} is not in the front end: {1}'.format(
        topic, discussion_title)
    discussion_link.click()
    ui_msg_2, ui_msg_1, = ms_viewer._gets(ms_viewer._comment_body)
    ui_msg_1 = ui_msg_1.text
    ui_msg_2 = ui_msg_2.text
    assert msg_1 == ui_msg_1, 'Sent message {0} is not the same from front end: {1}'\
        .format(msg_1, ui_msg_1)
    assert msg_2 in ui_msg_2, 'Sent message {0} is not in the front end: {1}'\
        .format(msg_2, ui_msg_2)

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
