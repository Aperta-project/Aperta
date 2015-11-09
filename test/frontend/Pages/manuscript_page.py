#!/usr/bin/env python2
# -*- coding: utf-8 -*-

__author__ = 'sbassi@plos.org'

from selenium.webdriver.common.by import By
from authenticated_page import AuthenticatedPage


class ManuscriptPage(AuthenticatedPage):
  """
  Model manuscript page
  """
  def __init__(self, driver):
    super(ManuscriptPage, self).__init__(driver, '/')

    #Locators - Instance members
    self._workflow_button = (By.XPATH, ".//a[contains(., 'Workflow')]")
    self._billing_card = (By.XPATH, "//div[@id='paper-assigned-tasks']//div[contains(., 'Billing')]")
    self._cover_letter_card = (By.XPATH, "//div[@id='paper-assigned-tasks']//div[contains(., 'Cover Letter')]")
    self._review_cands_card = (By.XPATH, "//div[@id='paper-assigned-tasks']//div[contains(., 'Reviewer Candidates')]")
    self._revise_task_card = (By.XPATH, "//div[@id='paper-assigned-tasks']//div[contains(., 'Revise Task')]")
    self._cfa_card = (By.XPATH, "//div[@id='paper-assigned-tasks']//div[contains(., 'Changes For Author')]")
    self._authors_card = (By.XPATH, "//div[@id='paper-metadata-tasks']//div[contains(., 'Authors')]")
    self._competing_ints_card = (By.XPATH, "//div[@id='paper-metadata-tasks']//div[contains(., 'Competing Interests')]")
    self._data_avail_card = (By.XPATH, "//div[@id='paper-metadata-tasks']//div[contains(., 'Data Availability')]")
    self._ethics_statement_card = (By.XPATH, "//div[@id='paper-metadata-tasks']//div[contains(., 'Ethics Statement')]")
    self._figures_card = (By.XPATH, "//div[@id='paper-metadata-tasks']//div[contains(., 'Figures')]")
    self._fin_disclose_card = (By.XPATH, "//div[@id='paper-metadata-tasks']//div[contains(., 'Financial Disclosure')]")
    self._new_taxon_card = (By.XPATH, "//div[@id='paper-metadata-tasks']//div[contains(., 'New Taxon')]")
    self._report_guide_card = (By.XPATH, "//div[@id='paper-metadata-tasks']//div[contains(., 'Reporting Guidelines')]")
    self._supporting_info_card = (By.XPATH, "//div[@id='paper-metadata-tasks']//div[contains(., 'Supporting Info')]")
    self._upload_manu_card = (By.XPATH, "//div[@id='paper-metadata-tasks']//div[contains(., 'Upload Manuscript')]")
    self._prq_card = (By.XPATH, "//div[@id='paper-metadata-tasks']//div[contains(., 'Publishing Related Questions')]")

  #POM Actions
  def click_workflow_button(self):
    """Click workflow button"""
    self._get(self._workflow_button).click()
    return self

  def click_authors_card(self):
    """ """
    authors_card_title = self._get(self._authors_card)
    authors_card_title.find_element_by_xpath('.//ancestor::a').click()
    return self

  def click_card(self, cardname):
    self.set_timeout(1)
    if cardname == 'cover_letter':
      card_title = self._get(self._billing_card)
    elif cardname == 'billing':
      card_title = self._get(self._cover_letter_card)
    elif cardname == 'figures':
      card_title = self._get(self._figures_card)
    elif cardname == 'authors':
      card_title = self._get(self._authors_card)
    elif cardname == 'supporting_info':
      card_title = self._get(self._supporting_info_card)
    elif cardname == 'upload_manuscript':
      card_title = self._get(self._upload_manu_card)
    elif cardname == 'prq':
      card_title = self._get(self._prq_card)
    elif cardname == 'review_candidates':
      card_title = self._get(self._review_cands_card)
    elif cardname == 'revise_task':
      card_title = self._get(self._revise_task_card)
    elif cardname == 'competing_interests':
      card_title = self._get(self._competing_ints_card)
    elif cardname == 'data_availability':
      card_title = self._get(self._data_avail_card)
    elif cardname == 'ethics_statement':
      card_title = self._get(self._ethics_statement_card)
    elif cardname == 'financial_disclosure':
      card_title = self._get(self._fin_disclose_card)
    elif cardname == 'new_taxon':
      card_title = self._get(self._new_taxon_card)
    elif cardname == 'reporting_guidelines':
      card_title = self._get(self._report_guide_card)
    elif cardname == 'changes_for_author':
      card_title = self._get(self._cfa_card)
    else:
      print('Unknown Card')
      self.restore_timeout()
      return False
    card_title.find_element_by_xpath('.//ancestor::a').click()
    self._bottom_close_button = (By.XPATH, '//div[@class="overlay-footer-content"]/a')
    self._get(self._bottom_close_button).click()
    self.restore_timeout()
    return True