#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta Discussion Forum
Automated test case for:
 * test discussion forum notification icons to MS
 * test discussion interactions
Note: Due to bug APERTA-8303 we import ascii only users instead of all users
"""

import logging
import os
import random
import time

from loremipsum import generate_paragraph
from dateutil import tz

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import ascii_only_users, editorial_users, staff_admin_login
from .Cards.invite_reviewer_card import InviteReviewersCard
from frontend.common_test import CommonTest
from .Pages.manuscript_viewer import ManuscriptViewerPage
from .Pages.workflow_page import WorkflowPage

__author__ = 'sbassi@plos.org'

staff_users = [staff_admin_login] + editorial_users


@MultiBrowserFixture
class DiscussionForumTest(CommonTest):
    """
    test_discussion_forum: Add discussion forum notification icons to MS
    AC out of: APERTA-5831
       - When the user is added to a discussion topic
       - When mentioned in a topic
       - Numbered notifications
    """

    def _test_notification(self):
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
        creator = random.choice(ascii_only_users)
        staff_user = random.choice(staff_users)
        logging.info('Creator: {0}'.format(creator))
        logging.info('Staff User: {0}'.format(staff_user))
        journal = 'PLOS Wombat'
        logging.info('Logging in as user: {0}'.format(creator))
        dashboard_page = self.cas_login(email=creator['email'])
        dashboard_page.page_ready()
        # Create paper
        dashboard_page.click_create_new_submission_button()
        time.sleep(.5)
        paper_type = 'OnlyInitialDecisionCard'
        logging.info('Creating Article in {0} of type {1}'.format(journal, paper_type))
        self.create_article(title='Testing Discussion Forum notifications', journal=journal,
                            type_=paper_type, random_bit=True)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        # check for flash message
        manuscript_page.page_ready_post_create()
        logging.info(manuscript_page.get_current_url())
        short_doi = manuscript_page.get_paper_short_doi_from_url()
        manuscript_page.logout()

        logging.info(u'Logging in as user: {0}'.format(staff_user))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        # go to article id short_doi
        dashboard_page.go_to_manuscript(short_doi)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        if web_page == 'manuscript viewer':
            # This is failing for Asian character set usernames of only two characters APERTA-7862
            manuscript_page.post_new_discussion(topic='Testing discussion on paper '
                                                      '{}'.format(short_doi),
                                                participants=[creator])
        elif web_page == 'workflow':
            manuscript_page.click_workflow_link()
            workflow_page = WorkflowPage(self.getDriver())
            workflow_page.page_ready()
            workflow_page.post_new_discussion(topic='Testing discussion on paper '
                                                    '{}'.format(short_doi), participants=[creator])
        manuscript_page.logout()

        logging.info(u'Logging in as user: {0}'.format(creator))
        dashboard_page = self.cas_login(email=creator['email'])
        dashboard_page.page_ready()
        dashboard_page.go_to_manuscript(short_doi)
        manuscript_page.page_ready()
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        # look for icon
        red_badge = manuscript_page._get(manuscript_page._badge_red)
        red_badge_first = int(red_badge.text)
        red_badge.click()
        time.sleep(.5)
        manuscript_page._get(manuscript_page._badge_red)
        manuscript_page.logout()

        logging.info(u'Logging in as user: {0}'.format(staff_user))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        # go to article id short_doi
        dashboard_page.go_to_manuscript(short_doi)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        # click on discussion icon
        manuscript_page.click_discussion_link()
        manuscript_page.post_discussion('@' + creator['user'])
        manuscript_page.logout()

        logging.info(u'Logging in as user: {0}'.format(creator))
        dashboard_page = self.cas_login(email=creator['email'])
        dashboard_page.page_ready()
        dashboard_page.go_to_manuscript(short_doi)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        # look for icon
        time.sleep(2)
        red_badge = manuscript_page._get(manuscript_page._badge_red)
        red_badge_last = int(red_badge.text)
        assert red_badge_first + 1 == red_badge_last, '{0} is different from {1}. This may be '\
            'caused by users with non ascii characters (Reported in ' \
                                                      'APERTA-8303)'.format(red_badge_first + 1,
                                                                            red_badge_last)
        red_badge.click()
        # look for red icon on workflow page?
        time.sleep(.5)
        manuscript_page._get(manuscript_page._first_discussion_lnk).click()
        time.sleep(.5)
        red_badge = manuscript_page._get(manuscript_page._comment_sheet_badge_red)
        red_badge_current = int(red_badge.text)
        assert red_badge_first == red_badge_current, '{0} is different from {1}'.format(
            red_badge_first, red_badge_last)
        # close and check if any badge
        manuscript_page.close_sheet()
        manuscript_page.set_timeout(2)
        try:
            manuscript_page._get(manuscript_page._badge_red)
            assert False, 'There should not be any discussion badge'
        except ElementDoesNotExistAssertionError:
            logging.info('There is no badge')
        manuscript_page.restore_timeout()

    def test_discussions(self):
        """
        This test validates a discussion from the manuscript view. It involves multiple
        participants, an admin user post a discussion and adds two collaborators.
        The collaborators checks for messages, one collaborator makes a post
        mentioning the other collaborator and this mention should be highlighted.
        All participants check for content, user and time.
        """
        web_page = random.choice(['manuscript viewer', 'workflow'])
        logging.info('Test discussion on: {0}'.format(web_page))
        # We use ascii_only_users because the feature itself doesn't support hi-ascii/dbl byte chars
        creator, collaborator_1, collaborator_2 = random.sample(ascii_only_users, 3)
        logging.info('Creator: {0}'.format(creator['name']))
        logging.info('Collaborator 1: {0}'.format(collaborator_1['name']))
        logging.info('Collaborator 2: {0}'.format(collaborator_2['name']))
        journal = 'PLOS Wombat'
        logging.info('Logging in as user: {0}'.format(creator['name']))
        dashboard_page = self.cas_login(email=creator['email'])
        dashboard_page.page_ready()
        # Create paper
        dashboard_page.click_create_new_submission_button()
        time.sleep(.5)
        paper_type = 'NoCards'
        logging.info('Creating Article in {0} of type {1}'.format(journal, paper_type))
        self.create_article(title='Testing Discussion Forum', journal=journal, type_=paper_type,
                            random_bit=True)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready_post_create()
        logging.info(manuscript_page.get_current_url())
        short_doi = manuscript_page.get_paper_short_doi_from_url()
        manuscript_page.complete_task('Upload Manuscript')
        manuscript_page.complete_task('Title And Abstract')

        # Submit paper
        manuscript_page.click_submit_btn()
        manuscript_page.confirm_submit_btn()
        manuscript_page.close_modal()

        # Once the paper is created, add collaborator 1
        user_id = PgSQL().query('SELECT id FROM users where username = %s;',
                                (collaborator_1['user'],))[0][0]
        journal_id = PgSQL().query('SELECT journal_id '
                                   'FROM papers WHERE short_doi = %s;', (short_doi,))[0][0]
        role_id = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s '
                                'AND name = %s;', (journal_id, 'Collaborator'))[0][0]
        paper_id = manuscript_page.get_paper_id_from_short_doi(short_doi)
        # Add collaborator directly via the db, NOT the GUI
        PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, '
                       'assigned_to_type, created_at, updated_at) VALUES (%s, %s, %s, \'Paper\','
                       ' now(), now());', (user_id, role_id, paper_id))
        # now add Collaborator 2
        user_id = PgSQL().query('SELECT id FROM users where username = %s;',
                                (collaborator_2['user'],))[0][0]
        PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, '
                       'assigned_to_type, created_at, updated_at) VALUES (%s, %s, %s, \'Paper\','
                       ' now(), now());', (user_id, role_id, paper_id))
        # Creator logout
        manuscript_page.logout()

        # Login as Staff user
        staff_user = random.choice(staff_users)
        reviewer_user = self.pick_reviewer()
        logging.info(u'Logging in as user: {0}'.format(staff_user))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        # go to article id short_doi
        dashboard_page.go_to_manuscript(short_doi)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready()
        topic = 'Testing discussion on paper {0}'.format(short_doi)
        msg_1 = generate_paragraph()[2]
        # How to call the discussion section
        if web_page == 'workflow':
            manuscript_page.post_new_discussion(topic=topic,
                                                msg=msg_1,
                                                participants=[collaborator_1,
                                                              collaborator_2])
        elif web_page == 'manuscript viewer':
            # Add Collaborator 1 and Collaborator 2
            manuscript_page._wait_for_element(manuscript_page._get(
                manuscript_page._tb_workflow_link))
            manuscript_page.post_new_discussion(topic=topic,
                                                msg=msg_1,
                                                participants=[collaborator_1,
                                                              collaborator_2])
            # APERTA-9117 Add a reviewer in order to verify they don't automatically see
            #     discussions.
            manuscript_page.click_workflow_link()
            workflow_page = WorkflowPage(self.getDriver())
            workflow_page.page_ready()
            workflow_page.click_card('invite_reviewers')
            invite_reviewers = InviteReviewersCard(self.getDriver())
            invite_reviewers.card_ready()
            invite_reviewers.invite(reviewer_user)
        # Staff user logout
        manuscript_page.logout()

        # Collaborator 1
        logging.info(u'Logging in as user Collaborator 1: {}'.format(collaborator_1))
        dashboard_page = self.cas_login(email=collaborator_1['email'])
        dashboard_page.page_ready()
        dashboard_page.go_to_manuscript(short_doi)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready()
        manuscript_page.click_discussion_link()
        discussion_link = manuscript_page._get(manuscript_page._first_discussion_lnk)
        discussion_title = discussion_link.text
        assert topic in discussion_title, '{0} not in {1}'.format(topic, discussion_title)
        discussion_link.click()
        created, discussion_topic_id = PgSQL().query('SELECT created_at, id '
                                                     'FROM discussion_topics '
                                                     'WHERE paper_id = %s;', (paper_id,))[0]
        from_zone = tz.gettz('UTC')
        to_zone = tz.tzlocal()
        created = created.replace(tzinfo=from_zone)
        db_time = created.astimezone(to_zone)
        # Note: %-d removes leading 0 only in Unix. If this suite ever going to be running
        # in Windows, we should detect OS and pass an alternative solution.
        db_time_fe_format = db_time.strftime('%B %-d, %Y %H:%M')
        comment_name = manuscript_page._get(manuscript_page._comment_name).text
        comment_date = manuscript_page._get(manuscript_page._comment_date).text
        header_fe = u'{0} {1}'.format(comment_name, comment_date)
        header_db = u'{0} posted {1}'.format(staff_user['name'], db_time_fe_format)
        assert header_fe == header_db, 'Header from the front end: {0} not the same as '\
                                       'in DB: {1}'.format(header_fe, header_db)
        comment_body = manuscript_page._get(manuscript_page._comment_body).text
        assert msg_1 == comment_body, 'Message sent: {0} not the message found in the '\
                                      'front end: {1}'.format(msg_1, comment_body)
        msg_2 = generate_paragraph()[2]
        discussion_back_link = manuscript_page._get(manuscript_page._discussion_back_link)
        discussion_back_link.click()
        manuscript_page.post_discussion(msg_2, mention=collaborator_2['user'])
        # Time needed for the new discussion to appear after AJAX call
        time.sleep(2)
        # Look for the mention and check style
        mention = manuscript_page.get_mention(collaborator_2['user'])
        assert mention, 'Mention {0} is not present in the post'.format(collaborator_2['user'])
        manuscript_page.validate_mention_style(mention)
        manuscript_page.logout()

        # Collaborator 2
        logging.info(u'Logging in as user Collaborator 2: {0}'.format(collaborator_2))
        dashboard_page = self.cas_login(email=collaborator_2['email'])
        dashboard_page.page_ready()
        # go to article id short_doi
        dashboard_page.go_to_manuscript(short_doi)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready()
        manuscript_page.click_discussion_link()
        discussion_link = manuscript_page._get(manuscript_page._first_discussion_lnk)
        discussion_title = discussion_link.text
        assert topic in discussion_title, '{0} not in {1}'.format(topic, discussion_title)
        discussion_link.click()
        # There are two relevant times for a discussion - the original creation time and the time
        # of the discussion and the time of a discussion reply. We should in all cases use the
        # latter of the two.
        logging.warning('Discusssion Topic ID: {0}'.format(discussion_topic_id))
        created = PgSQL().query('SELECT created_at '
                                'FROM discussion_replies '
                                'WHERE discussion_topic_id = %s '
                                'ORDER BY id DESC '
                                'LIMIT 1;', (discussion_topic_id,))[0][0]
        from_zone = tz.gettz('UTC')
        to_zone = tz.tzlocal()
        created = created.replace(tzinfo=from_zone)
        db_time = created.astimezone(to_zone)
        # Note: %-d removes leading 0 only in Unix. If this suite ever going to be running
        # in Windows, we should detect OS and pass an alternative solution.
        db_time_fe_format = db_time.strftime('%B %-d, %Y %H:%M')
        comment_name = manuscript_page._get(manuscript_page._comment_name).text
        comment_date = manuscript_page._get(manuscript_page._comment_date).text
        header_fe = u'{0} {1}'.format(comment_name, comment_date)
        header_db = u'{0} posted {1}'.format(collaborator_1['name'], db_time_fe_format)
        assert header_fe == header_db, 'Header from front end: {0}, is not the same as '\
                                       'header from the DB: {1}'.format(header_fe, header_db)
        comment_body = manuscript_page._get(manuscript_page._comment_body).text
        assert msg_2 in comment_body, 'Message sent: {0} is not in the front end {1}'\
            .format(msg_2, comment_body)
        manuscript_page.logout()

        # Login as Staff user
        logging.info(u'Logging in as user: {0}'.format(staff_user))
        dashboard_page = self.cas_login(email=staff_user['email'])
        dashboard_page.page_ready()
        # go to article id short_doi
        dashboard_page.go_to_manuscript(short_doi)
        manuscript_page = ManuscriptViewerPage(self.getDriver())
        manuscript_page.page_ready()
        manuscript_page.click_discussion_link()
        try:
            discussion_link = manuscript_page._get(manuscript_page._first_discussion_lnk)
        except ElementDoesNotExistAssertionError:
            raise(ElementDoesNotExistAssertionError, 'This may be caused by the user {0} not being '
                                                     'able to see its own discussion '
                                                     '(reported at APERTA-7902)'.format(staff_user))
        discussion_title = discussion_link.text
        assert topic in discussion_title, 'Sent topic: {0} is not in the front end: {1}'.format(
            topic, discussion_title)
        discussion_link.click()
        ui_msg_2, ui_msg_1, = manuscript_page._gets(manuscript_page._comment_body)
        ui_msg_1 = ui_msg_1.text
        ui_msg_2 = ui_msg_2.text
        assert msg_1 == ui_msg_1, 'Sent message {0} is not the same from front end: {1}'\
            .format(msg_1, ui_msg_1)
        assert msg_2 in ui_msg_2, 'Sent message {0} is not in the front end: {1}'\
            .format(msg_2, ui_msg_2)

        if web_page == 'manuscript viewer':
            manuscript_title = manuscript_page.get_paper_title_from_page()
            manuscript_page.logout()
            # APERTA-9117
            dashboard_page = self.cas_login(email=reviewer_user['email'])
            dashboard_page.page_ready()
            dashboard_page.click_view_invitations()
            dashboard_page.accept_invitation(title=manuscript_title)
            paper_viewer = ManuscriptViewerPage(self.getDriver())
            paper_viewer.page_ready()
            paper_viewer.click_discussion_link()
            paper_viewer.set_timeout(5)
            try:
                paper_viewer._get(paper_viewer._first_discussion_lnk)
                raise AssertionError('Discussion found when reviewer should not have access.')
            except ElementDoesNotExistAssertionError as e:
                # We should get this failure.
                logging.info(e)
            finally:
                paper_viewer.restore_timeout()

    if __name__ == '__main__':
        CommonTest.run_tests_randomly()
