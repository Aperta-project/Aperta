#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates style and function of the Supporting Information (SI) Card
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted into
    frontend/assets/
"""
import logging
import os
import random
import time

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.Resources import docs, users, editorial_users
from frontend.common_test import CommonTest
from frontend.Tasks.supporting_information_task import SITask
from frontend.Cards.supporting_information_card import SICard
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

from loremipsum import generate_paragraph

__author__ = 'sbassi@plos.org'

@MultiBrowserFixture
class SITaskTest(CommonTest):
  """
  Validate the elements, styles, functions of the Revision Tech Check task
  """

  def test_si_task_and_card(self):
    """
    test_si_card: Validates the elements, styles, and functions (Add, edit, delete) of SI Task
    :return: None
    """
    logging.info('Test SITask')
    creator_user = random.choice(users)
    logging.info(creator_user)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_url = manuscript_page.get_current_url()
    short_doi = manuscript_page.get_short_doi()
    logging.info('The paper URL of this newly created paper is: {0}'.format(paper_url))
    doc2upload = random.choice(docs)
    fn = os.path.join(os.getcwd(), doc2upload)
    data = {}
    data['file_name'] = fn
    data['figure'] = 'S1'
    choices = ('Table', 'Data', 'Text', 'Figure')
    # Note: 'Other' option is tested in the next task completion
    file_type = random.choice(choices)
    logging.info('Selected file type: {0}'.format(file_type))
    data['type'] = file_type
    data['title'] = generate_paragraph()[2][:15]
    data['caption'] = generate_paragraph()[2][:35]
    manuscript_page.complete_task('Supporting Info', data=data)
    # check for data
    manuscript_page.click_task('Supporting Info')
    # locate elements
    supporting_info = SITask(self._driver)
    figure_data = supporting_info._get(supporting_info._si_file_title_display)
    figure_line = '{0} {1}. {2}'.format(data['figure'], data['type'], data['title'])
    assert figure_line == figure_data.text, (figure_line, figure_data.text)
    caption_data = supporting_info._get(supporting_info._si_file_caption_display)
    assert data['caption'].strip() == caption_data.text, (data['caption'], caption_data.text)
    # press make change to task
    supporting_info.click_completion_button()
    # Edit description
    time.sleep(2)
    edit_icon = supporting_info._get(supporting_info._si_pencil_icon)
    edit_icon.click()
    # new data
    data['figure'] = 'S2'
    choices = ('Table', 'Data', 'Text', 'Figure', 'Other')
    file_type = random.choice(choices)
    logging.info('Selected file type: {0}'.format(file_type))
    data['type'] = file_type
    data['title'] = generate_paragraph()[2][:15]
    data['caption'] = generate_paragraph()[2][:35]
    supporting_info.complete_si_item_form(data)
    supporting_info = SITask(self._driver)
    figure_data = supporting_info._get(supporting_info._si_file_title_display)
    figure_line = '{0} {1}. {2}'.format(data['figure'], data['type'], data['title'])
    assert figure_line == figure_data.text, (figure_line, figure_data.text)
    caption_data = supporting_info._get(supporting_info._si_file_caption_display)
    assert data['caption'].strip() == caption_data.text, (data['caption'], caption_data.text)
    # logout
    manuscript_page.logout()
    # Log in as Editorial User
    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    paper_workflow_url = '{0}/workflow'.format(paper_url.split('?')[0])
    self._driver.get(paper_workflow_url)
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_supporting_information_card()
    supporting_info_card = SICard(self._driver)
    supporting_info_card.validate_styles(short_doi)
    supporting_info_card.check_si_item(data)
    # go back to article
    manuscript_page.logout()
    # Login as creator
    logging.info(creator_user)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    self._driver.get(paper_url)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    manuscript_page.click_task('Supporting Info')
    # locate elements
    supporting_info = SITask(self._driver)
    # Try delete it
    del_icon = supporting_info._get(supporting_info._si_trash_icon)
    del_icon.click()
    del_button = supporting_info._get(supporting_info._si_file_del_btn)
    assert del_button.text == 'DELETE FOREVER', del_button.text
    supporting_info.delete_forever_btn_style_validation(del_button)
    del_button.click()
    time.sleep(3)
    # Check that is deleted
    supporting_info.set_timeout(2)
    try:
      supporting_info._get(supporting_info._si_trash_icon)
      raise(StandardError, 'Item not deleted')
    except ElementDoesNotExistAssertionError:
      pass
    supporting_info.restore_timeout()

  def test_multiple_si_uploads(self):
    """
    test_figure_task: Validates the upload function of the figures task
    :return: void function
    """
    creator_user = random.choice(users)
    logging.info(creator_user)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_url = manuscript_page.get_current_url()
    short_doi = manuscript_page.get_short_doi()
    logging.info('The paper URL of this newly created paper is: {0}'.format(paper_url))
    manuscript_page.click_task('Supporting Info')
    # locate elements
    supporting_info = SITask(self._driver)
    doc2uploads = [os.path.join(os.getcwd(), x) for x in random.sample(docs, 4)]
    logging.info(doc2uploads)
    supporting_info.add_files(doc2uploads)
    supporting_info.validate_uploads(doc2uploads)
    return None

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
