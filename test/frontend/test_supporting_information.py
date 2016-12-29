#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates style and function of the Supporting Information (SI) Card and Task
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/testing_assets.tar.gz extracted
    into frontend/assets/
"""
import logging
import os
import random
import time

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.Resources import docs, figures, supporting_info_files, users, editorial_users
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
  Validate the elements, styles, functions of the Supporting Information task
  """

  def test_si_task_styles(self):
    """
    test_si_card: Validates the elements, styles SI Task
    :return: None
    """
    creator_user = random.choice(users)
    logging.info('Login as {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    short_doi = manuscript_page.get_short_doi()
    doc2upload = 'frontend/assets/supportingInfo/ucsd_student_survey_data.csv'
    fn = os.path.join(os.getcwd(), doc2upload)
    data = {}
    data['file_name'] = fn
    data['figure'] = 'S1'
    data['type'] = 'Text'
    data['title'] = 'Title'
    data['caption'] = 'Caption'
    manuscript_page.complete_task('Supporting Info', data=data)
    # get link
    manuscript_page.click_task('Supporting Info')
    #tasks = manuscript_page._gets(manuscript_page._task_headings)
    #for task in tasks:
    #  if 'Supporting Info' in task.text:
    #    task.click()
        #self.click_covered_element(task)
    # search for link
    supporting_info = SITask(self._driver)
    # task completed
    supporting_info.click_completion_button()
    time.sleep(2)
    file_link = supporting_info._get(supporting_info._file_link)
    supporting_info.validate_uploads_styles(file_link)
    return None

  def test_si_task_and_card(self):
    """
    test_si_card: Validates the elements, styles, and functions (Add, edit, delete) of SI Task
    :return: None
    """
    creator_user = random.choice(users)
    logging.info('Login as {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_url = manuscript_page.get_current_url()
    short_doi = manuscript_page.get_short_doi()
    logging.info('The paper URL of this newly created paper is: {0}'.format(paper_url))
    si_files = docs + figures + supporting_info_files
    doc2upload = random.choice(si_files)
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
    # Following sleep time is to avoid a Stale Element Reference Exception
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
    # go to paper
    self._driver.get(paper_url)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    manuscript_page.click_workflow_link()
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
    # Following sleep accounts for waiting for an element to detach from the DOM, time is
    # needed because next action is to check for item presence. If there is no wait, there
    # will be a false positive
    time.sleep(3)
    # Check that is deleted
    supporting_info.set_timeout(2)
    try:
      supporting_info._get(supporting_info._si_trash_icon)
      raise(StandardError, 'Item not deleted')
    except ElementDoesNotExistAssertionError:
      pass
    supporting_info.restore_timeout()

  def test_replace_si_upload(self):
    """
    test_figure_task: Validates replace function in SI task
    :return: None
    """
    creator_user = random.choice(users)
    logging.info('Login as {0}'.format(creator_user))
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.page_ready()
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    ##short_doi = manuscript_page.get_short_doi()
    paper_url = manuscript_page.get_current_url()
    logging.info('The paper URL of this newly created paper is: {0}'.format(paper_url))
    doc2upload_1 = 'frontend/assets/supportingInfo/S2_other.XSLX'
    fn = os.path.join(os.getcwd(), doc2upload_1)
    manuscript_page.click_task('Supporting Info')
    supporting_info = SITask(self._driver)
    supporting_info.add_file(fn)
    supporting_info.validate_uploads([fn])
    # click edit
    edit_btn = supporting_info._get(supporting_info._si_pencil_icon)
    edit_btn.click()
    # check for reeplace symbol
    replace_div = supporting_info._get(supporting_info._si_replace_div)
    replace_input = replace_div.find_element(*supporting_info._si_replace_input)
    doc2upload_2 = 'frontend/assets/supportingInfo/S1_Text.pdf'
    fn = os.path.join(os.getcwd(), doc2upload_2)
    replace_input.send_keys(fn)
    # Time for the file to upload and cancel button to attach
    time.sleep(12)
    cancel_btn = supporting_info._get(supporting_info._si_file_cancel_btn)
    cancel_btn.click()
    # Get current SI file name
    file_link_text = supporting_info._get(supporting_info._file_link).text
    timeout = 60
    counter = 0
    while file_link_text in doc2upload_1 or counter == timeout:
      file_link_text = supporting_info._get(supporting_info._file_link).text
      time.sleep(1)
      counter += 1
    supporting_info.validate_uploads([fn])
    manuscript_page.logout()
    # Log in as Editorial User
    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    # go to paper
    self._driver.get(paper_url)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    manuscript_page.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_supporting_information_card()
    supporting_info_card = SICard(self._driver)
    supporting_info_card.validate_uploads([fn])
    # make a replacement
    edit_btn = supporting_info._get(supporting_info._si_pencil_icon)
    edit_btn.click()
    replace_div = supporting_info._get(supporting_info._si_replace_div)
    replace_input = replace_div.find_element(*supporting_info._si_replace_input)
    doc2upload = 'frontend/assets/supportingInfo/S2_other.XSLX'
    fn = os.path.join(os.getcwd(), doc2upload)
    replace_input.send_keys(fn)
    # Time for the file to upload and cancel button to attach
    time.sleep(12)
    cancel_btn = supporting_info._get(supporting_info._si_file_cancel_btn)
    cancel_btn.click()
    supporting_info.validate_uploads([fn])
    return None

  def test_multiple_si_uploads(self):
    """
    test_figure_task: Validates the upload function for miltiple files in SI task
    and in SI Card
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
    logging.info('The paper URL of this newly created paper is: {0}'.format(paper_url))
    manuscript_page.click_task('Supporting Info')
    # locate elements
    supporting_info = SITask(self._driver)
    si_files = docs + figures + supporting_info_files
    doc2uploads = [os.path.join(os.getcwd(), x) for x in random.sample(si_files, 4)]
    logging.info(doc2uploads)
    supporting_info.add_files(doc2uploads)
    # Wait for all files to upload and process for testing for uploads
    # Bug reported at APERTA-8720
    time.sleep(12)
    supporting_info.validate_uploads(doc2uploads)
    manuscript_page.logout()
    # check from the editor POV
    # see if all uploads are there
    # Log in as Editorial User
    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    dashboard_page.page_ready()
    # go to paper
    self._driver.get(paper_url)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready()
    manuscript_page.click_workflow_link()
    workflow_page = WorkflowPage(self.getDriver())
    workflow_page.page_ready()
    workflow_page.click_supporting_information_card()
    supporting_info_card = SICard(self._driver)
    supporting_info_card.validate_uploads(doc2uploads)
    # upload multiple files in the card
    si_files = supporting_info_files
    doc2uploads_set2 = [os.path.join(os.getcwd(), x) for x in random.sample(si_files, 4)]
    logging.info(doc2uploads_set2)
    supporting_info_card.add_files(doc2uploads_set2)
    # Wait for all files to upload and process for testing for uploads
    time.sleep(12)
    supporting_info_card.validate_uploads(doc2uploads + doc2uploads_set2)
    return None

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
