#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates style and function of  Production Metadata card
This test requires the following data:
The test document tarball from http://bighector.plos.org/aperta/docs.tar.gz extracted into
    frontend/assets/docs/
"""
import logging
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.PostgreSQL import PgSQL
from Base.Resources import creator_login1, creator_login2, creator_login3, creator_login4, \
    creator_login5, staff_admin_login, internal_editor_login, prod_staff_login, pub_svcs_login, \
    super_admin_login, academic_editor_login
from frontend.common_test import CommonTest
from Cards.production_metadata_card import ProductionMedataCard
from Pages.manuscript_viewer import ManuscriptViewerPage
from Pages.workflow_page import WorkflowPage

__author__ = 'sbassi@plos.org'

users = [creator_login1,
         creator_login2,
         creator_login3,
         creator_login4,
         creator_login5,
         ]

editorial_users = [internal_editor_login,
                   staff_admin_login,
                   super_admin_login,
                   prod_staff_login,
                   pub_svcs_login,
                   ]

@MultiBrowserFixture
class ProductionMetadataCardTest(CommonTest):
  """
  Validate the elements, styles, functions of the Production Metadata card
  """

  def test_production_metadata_card(self):
    """
    test_invite_ae: Validates the elements, styles, roles and functions of invite academic
    editors from new document creation through inviting ae, validation of the invite on the
    invitees dashboard, acceptance and rejections
    :return: void function
    """
    # Users logs in and make a submission
    creator_user = random.choice(users)
    dashboard_page = self.cas_login(email=creator_user['email'])
    dashboard_page.set_timeout(60)
    dashboard_page.click_create_new_submission_button()
    self.create_article(journal='PLOS Wombat',
                        type_='OnlyInitialDecisionCard',
                        random_bit=True,
                        )
    dashboard_page.restore_timeout()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(5)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success()
    paper_url = manuscript_page.get_current_url()
    paper_id = paper_url.split('/')[-1]
    logging.info('The paper ID of this newly created paper is: {0}'.format(paper_id))
    manuscript_page.click_submit_btn()
    manuscript_page.confirm_submit_btn()
    # Now we get the submit confirmation overlay
    # Sadly, we take time to switch the overlay
    time.sleep(2)
    manuscript_page.close_modal()
    # logout and enter as editor
    manuscript_page.logout()
    editorial_user = random.choice(editorial_users)
    logging.info('Logging in as {0}'.format(editorial_user))
    dashboard_page = self.cas_login(email=editorial_user['email'])
    paper_workflow_url = '{0}/workflow'.format(paper_url)
    self._driver.get(paper_workflow_url)
    workflow_page = WorkflowPage(self.getDriver())
    # Need to provide time for the workflow page to load and for the elements to attach to DOM,
    # otherwise failures
    time.sleep(4)
    # Check if card is there
    if not workflow_page.is_card('Production Metadata'):
      workflow_page.add_card('Production Metadata')
    # click on invite academic editor
    workflow_page.click_production_metadata_card()
    product_metadata_card = ProductionMedataCard(self.getDriver())
    product_metadata_card.check_style(academic_editor_login)
    # test content, it should be saved
    data = product_metadata_card.complete_card()
    time.sleep(2)
    workflow_page.click_production_metadata_card()
    # read card data in the DB and compare
    task_id = PgSQL().query(
        'SELECT id from tasks WHERE paper_id = %s and title = %s;',
        (paper_id,'Production Metadata'))[0][0]
    nested_queston = PgSQL().query(
        'SELECT nested_question_id, value from nested_question_answers '
        'WHERE owner_id = %s and owner_type=%s;', (task_id,'Task'))
    answers = [x[1] for  x in nested_queston]
    for item in data.values():
      assert item in answers,  (item, answers)
    workflow_page.logout()


if __name__ == '__main__':
  CommonTest._run_tests_randomly()
