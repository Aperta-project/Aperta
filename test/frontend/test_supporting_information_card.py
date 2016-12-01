#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates style and function of the Supporting Information (SI) Card
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import os
import random

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Decorators import MultiBrowserFixture
from Base.Resources import docs, users, editorial_users
from frontend.common_test import CommonTest
from frontend.Tasks.supporting_information_task import SITask
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

from loremipsum import generate_paragraph

__author__ = 'sbassi@plos.org'

@MultiBrowserFixture
class SITaskTest(CommonTest):
  """
  Validate the elements, styles, functions of the Revision Tech Check card
  """

  def test_si_task(self):
    """
    test_si_card: Validates the elements, styles, and functions of RTC Card
    :return: void function
    """
    logging.info('Test SITask')
    creator_user = random.choice(users)
    logging.info(creator_user)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat', type_='Research', random_bit=True)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.page_ready_post_create()
    paper_id = manuscript_page.get_paper_id_from_url()
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    doc2upload = random.choice(docs)
    fn = os.path.join(os.getcwd(), 'frontend/assets/docs/', doc2upload)
    data = {}
    data['file_name'] = fn
    data['figure'] = 'S1'
    file_type = random.choice(['Table', 'Data', 'Text', 'Figure', 'Other'])
    logging.info(file_type)
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
    assert data['caption'] == caption_data.text, (data['caption'], caption_data.text)
    # Try delete it
    # press make change to task
    supporting_info.click_completion_button()

    del_icon = supporting_info._get(supporting_info._si_trash_icon)
    del_icon.click()
    del_button = supporting_info._get(supporting_info._si_file_del_btn)
    assert del_button.text == 'DELETE FOREVER', del_button.text
    del_button.click()


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
