#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By

from authenticated_page import AuthenticatedPage, APPLICATION_TYPEFACE
from Base.CustomException import ElementDoesNotExistAssertionError
from frontend.Cards.basecard import BaseCard
from frontend.Cards.initial_decision_card import InitialDecisionCard
from frontend.Cards.register_decision_card import RegisterDecisionCard

__author__ = 'sbassi@plos.org'


class WorkflowPage(AuthenticatedPage):
  """
  Model workflow page
  """
  def __init__(self, driver):
    super(WorkflowPage, self).__init__(driver, '/')

    # Locators - Instance members
    self._click_editor_assignment_button = (By.XPATH, './/div[2]/div[2]/div/div[4]/div')
    self._navigation_menu_line = (By.XPATH, ".//div[@class='navigation']/hr")
    self._manuscript_icon = (By.XPATH,
        ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[4]/div/div/*[local-name() \
        = 'svg']/*[local-name() = 'path']")
    self._manuscript_link = (By.XPATH, "//div[@class='control-bar-inner-wrapper']/ul[2]/li[4]/a")
    self._manuscript_text = (By.XPATH,
                             ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[4]/div/div[2]")
    self._column_header = (By.XPATH, ".//div[contains(@class, 'column-header')]/div/h2")
    self._column_header_save = (By.XPATH,
                                ".//div[contains(@class, 'column-header')]/div/div/button[2]")
    self._column_header_cancel = (By.XPATH,
                                  ".//div[contains(@class, 'column-header')]/div/div/button")
    self._add_new_card_button = (By.CLASS_NAME, "add-new-card-button")
    self._select_in_overlay = (By.XPATH, ".//div[contains(@class, 'select2-container')]/input")
    self._add_button_overlay = (By.XPATH, ".//div[@class='overlay-action-buttons']/button[1]")
    self._cancel_button_overlay = (By.XPATH,  ".//div[@class='overlay-action-buttons']/button[2]")
    self._first_column = (By.XPATH,  ".//div[@class='column-content']/div")
    self._first_column_cards = (By.CSS_SELECTOR, 'div.card')
    # Note: Not used due to not reaching this menu from automation
    self._remove_confirmation_title = (By.XPATH, ".//div[contains(@class, 'delete-card-title')]/h1")
    self._remove_confirmation_subtitle = (By.XPATH,
                                          ".//div[contains(@class, 'delete-card-title')]/h2")
    self._remove_yes_button = (By.XPATH,
                               ".//div[contains(@class, 'delete-card-action-buttons')]/div/button")
    self._remove_cancel_button = (By.XPATH, ".//div[contains(@class, 'delete-card-action-buttons')]\
        /div[2]/button")
    self._add_card_overlay_div = (By.CSS_SELECTOR, 'div.overlay-container')
    self._add_card_overlay_columns = (By.CLASS_NAME, 'col-md-4')
    # Card Locators
    self._addl_info_card = (By.CSS_SELECTOR, 'div.publishing-related-questions-task > a')
    self._authors_card = (By.CSS_SELECTOR, 'div.authors-task > a')
    self._assign_team_card = (By.CSS_SELECTOR, 'div.assign-team-task > a')
    self._billing_card = (By.CSS_SELECTOR, 'div.billing-task > a')
    self._cfa_card = (By.CSS_SELECTOR, 'div.changes-for-author-task > a')
    self._competing_ints_card = (By.CSS_SELECTOR, 'div.competing-interests-task > a')
    self._cover_letter_card = (By.CSS_SELECTOR, 'div.cover-letter-task > a')
    self._data_avail_card = (By.CSS_SELECTOR, 'div.data-availability-task > a')
    self._early_article_posting_card = (By.CSS_SELECTOR, 'div.early-posting-task > a')
    self._editor_discussion_card = (By.CSS_SELECTOR, 'div.editors-discussion-task > a')
    self._ethics_statement_card = (By.CSS_SELECTOR, 'div.ethics-task > a')
    self._figures_card = (By.CSS_SELECTOR, 'div.figure-task > a')
    self._final_tech_check_card = (By.CSS_SELECTOR, 'div.final-tech-check-task > a')
    self._financial_disclosure_card = (By.CSS_SELECTOR, 'div.financial-disclosure-task > a')
    self._initial_decision_card = (By.CSS_SELECTOR, 'div.initial-decision-task > a')
    self._initial_tech_check_card = (By.CSS_SELECTOR, 'div.initial-tech-check-task > a')
    self._invite_ae_card = (By.CSS_SELECTOR, 'div.paper-editor-task > a')
    self._invite_reviewers_card = (By.CSS_SELECTOR, 'div.paper-reviewer-task > a')
    self._new_taxon_card = (By.CSS_SELECTOR, 'div.taxon-task > a')
    self._production_metadata_card = (By.CSS_SELECTOR, 'div.production-metadata-task > a')
    self._register_decision_card = (By.CSS_SELECTOR, 'div.register-decision-task > a')
    self._related_articles_card = (By.CSS_SELECTOR, 'div.related-articles-task > a')
    self._report_guide_card = (By.CSS_SELECTOR, 'div.reporting-guidelines-task > a')
    self._review_cands_card = (By.CSS_SELECTOR, 'div.reviewer-recommendations-task > a')
    self._reviewer_report_card = (By.CSS_SELECTOR, 'div.reviewer-report-task > a')
    self._revise_task_card = (By.CSS_SELECTOR, 'div.revise-task > a')
    self._revision_tech_check_card = (By.CSS_SELECTOR, 'div.revision-tech-check-task > a')
    self._send_to_apex_card = (By.CSS_SELECTOR, 'div.send-to-apex-task > a')
    self._supporting_info_card = (By.CSS_SELECTOR, 'div.supporting-information-task > a')
    self._title_abstract_card = (By.CSS_SELECTOR, 'div.title-and-abstract-task > a')
    self._upload_manu_card = (By.CSS_SELECTOR, 'div.upload-manuscript-task > a')
    self._ad_hoc_editors_card = (By.XPATH, "//a/span[contains(., 'Ad-hoc for Editors')]")
    self._ad_hoc_reviewers_card = (By.XPATH, "//a/span[contains(., 'Ad-hoc for Reviewers')]")
    self._ad_hoc_authors_card = (By.XPATH, "//a/span[contains(., 'Ad-hoc for Authors')]")
    self._ad_hoc_staff_card = (By.XPATH, "//a/span[contains(., 'Ad-hoc for Staff Only')]")
    self._reviewed_by_card = (By.CSS_SELECTOR, 'div.reviewer-report-task > a')
    self._cards = (By.CSS_SELECTOR, 'div.card')
    self._card_types = (By.CSS_SELECTOR, 'div.row label')
    self._div_buttons = (By.CSS_SELECTOR, 'div.overlay-action-buttons')

  # POM Actions
  def validate_initial_page_elements_styles(self):
    """
    Validate the presence and style of the workflow page toolbar and top elements along with
      column header elements.
    :return: void function
    """
    # Validate menu elements (title and icon)
    assert self._get(self._toolbar_items)
    self.validate_wf_top_elements()
    assert self._get(self._column_header)

  def click_initial_decision_card(self):
    """Open the Initial Decision Card from the workflow page"""
    self._get(self._initial_decision_card).click()

  def click_supporting_information_card(self):
    """Open the Supporting Information Card from the workflow page"""
    self._get(self._supporting_info_card).click()

  def click_ad_hoc_reviewer_card(self):
    """Open Ad Hoc Reviewer Card from the workflow page"""
    self._get(self._ad_hoc_reviewers_card).click()

  def click_ad_hoc_editor_card(self):
    """Open Ad Hoc Editor Card from the workflow page"""
    self._get(self._ad_hoc_editors_card).click()

  def click_ad_hoc_staff_card(self):
    """Open Ad Hoc Reviewer Staff Only from the workflow page"""
    self._get(self._ad_hoc_staff_card).click()

  def click_initial_tech_check_card(self):
    """Open the Initial Tech Check Card from the workflow page"""
    self._get(self._initial_tech_check_card).click()

  def click_final_tech_check_card(self):
    """Open the Final Tech Check Card from the workflow page"""
    self._get(self._final_tech_check_card).click()

  def click_revision_tech_check_card(self):
    """Open the Revision Tech Check Card from the workflow page"""
    self._get(self._revision_tech_check_card).click()

  def click_production_metadata_card(self):
    """Open the Initial Decision Card from the workflow page"""
    self._get(self._production_metadata_card).click()

  def click_editor_assignment_button(self):
    """Click editor assignment button"""
    self._get(self._click_editor_assignment_button).click()
    return self

  def click_invite_editor_card(self):
    """Click Invite Academic Editor Card"""
    self._get(self._invite_editor_card).click()

  def click_invite_ae_card(self):
    """Click Invite Academic Editor Card"""
    self._get(self._invite_ae_card).click()

  def click_register_decision_card(self):
    """Open the Register Decison Card from the workflow page"""
    self._get(self._register_decision_card).click()

  def click_ad_hoc_authors_card(self):
    """Open the Ad Hoc author card"""
    self._get(self._ad_hoc_authors_card).click()

  def click_column_header(self):
    """Click on the first column header and returns the text"""
    column_header = self._get(self._column_header)
    column_header.click()
    return column_header.text

  def click_cancel_column_header(self):
    """
    Click the cancel button of the column header when in edit mode
    :return: void function
    """
    self._get(self._column_header_cancel).click()

  def modify_column_header(self, title, blank=True):
    """
    Edit the column header to title
    :param title: The text to use in renaming the workflow column heading
    :param blank: if blank, replace the heading with title, if not blank, append title to heading
    :return: void function
    """
    column_header = self._get(self._column_header)
    if blank:
      column_header.clear()
    column_header.send_keys(title)
    self._get(self._column_header_save).click()

  def click_add_new_card(self):
    """Click on the add new card button on workflow"""
    self._get(self._add_new_card_button).click()
    return self

  def is_card(self, card_name):
    """
    Check if a card is present in the workflow
    :param card_name: String with the name of the card
    :returns: Bool
    """
    self.set_timeout(120)
    all_cards = self._gets(self._cards)
    self.restore_timeout()
    card_titles = [card.text for card in all_cards]
    if card_name in card_titles:
      return True
    else:
      return False

  def check_overlay(self):
    """
    Check CSS properties of the overlay that appears when the user click on add new card
    TODO: Disabled until StyleGuide is ready: APERTA-5414
    """
    card_overlay = self._get(self._add_card_overlay_div)
    assert card_overlay.text == 'Pick the type of card to add'
    self.validate_application_title_style(card_overlay)
    assert card_overlay.value_of_css_property('text-align') == 'center'
    close_icon_overlay = self._get(self._close_icon_overlay)
    # TODO: Change following line after bug #102078080 is solved
    assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px')
    assert APPLICATION_TYPEFACE in close_icon_overlay.value_of_css_property('font-family')
    assert close_icon_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    select_task = self._get(self._select_in_overlay)
    assert APPLICATION_TYPEFACE in select_task.value_of_css_property('font-family')
    assert select_task.value_of_css_property('font-size') == '14px'
    assert select_task.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    add_button_overlay = self._get(self._add_button_overlay)
    self.validate_primary_big_green_button_style(add_button_overlay)
    assert add_button_overlay.text == 'ADD'
    cancel_button_overlay = self._get(self._cancel_button_overlay)
    assert APPLICATION_TYPEFACE in cancel_button_overlay.value_of_css_property('font-family')
    assert cancel_button_overlay.value_of_css_property('font-size') == '14px'
    assert cancel_button_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert cancel_button_overlay.value_of_css_property('text-align') == 'center'
    assert cancel_button_overlay.text == 'cancel'
    return self

  def check_new_tasks_overlay(self):
    """
    On the add new task overlay, select a card
    For APERTA-5513, check cards
    """
    # Get card list
    # APERTA-5513 AC 1 and 2
    author_col, staff_col, custom_col = self._gets(self._add_card_overlay_columns)
    author_cards = author_col.find_elements_by_tag_name('label')
    assert author_cards[0].text == u'Additional Information', author_cards[0].text
    assert author_cards[1].text == u'Authors', author_cards[1].text
    assert author_cards[2].text == u'Billing', author_cards[2].text
    assert author_cards[3].text == u'Competing Interests', author_cards[3].text
    assert author_cards[4].text == u'Cover Letter', author_cards[4].text
    assert author_cards[5].text == u'Data Availability', author_cards[5].text
    assert author_cards[6].text == u'Early Article Posting', author_cards[6].text
    assert author_cards[7].text == u'Ethics Statement', author_cards[7].text
    assert author_cards[8].text == u'Figures', author_cards[8].text
    assert author_cards[9].text == u'Financial Disclosure', author_cards[9].text
    assert author_cards[10].text == u'New Taxon', author_cards[10].text
    assert author_cards[11].text == u'Reporting Guidelines', author_cards[11].text
    assert author_cards[12].text == u'Reviewer Candidates', author_cards[12].text
    assert author_cards[13].text == u'Supporting Info', author_cards[13].text
    assert author_cards[14].text == u'Upload Manuscript', author_cards[14].text
    staff_cards = staff_col.find_elements_by_tag_name('label')
    assert staff_cards[0].text == u'Ad-hoc for Authors', staff_cards[0].text
    assert staff_cards[1].text == u'Ad-hoc for Editors', staff_cards[1].text
    assert staff_cards[2].text == u'Ad-hoc for Reviewers', staff_cards[2].text
    assert staff_cards[3].text == u'Ad-hoc for Staff Only', staff_cards[3].text
    assert staff_cards[4].text == u'Assign Team', staff_cards[4].text
    assert staff_cards[5].text == u'Custom Card', staff_cards[5].text
    assert staff_cards[6].text == u'Editor Discussion', staff_cards[6].text
    assert staff_cards[7].text == u'Final Tech Check', staff_cards[7].text
    assert staff_cards[8].text == u'Initial Decision', staff_cards[8].text
    assert staff_cards[9].text == u'Initial Tech Check', staff_cards[9].text
    assert staff_cards[10].text == u'Invite Academic Editor', staff_cards[10].text
    assert staff_cards[11].text == u'Invite Reviewers', staff_cards[11].text
    assert staff_cards[12].text == u'Production Metadata', staff_cards[12].text
    assert staff_cards[13].text == u'Register Decision', staff_cards[13].text
    assert staff_cards[14].text == u'Related Articles', staff_cards[14].text
    assert staff_cards[15].text == u'Revision Tech Check', staff_cards[15].text
    assert staff_cards[16].text == u'Send to Apex', staff_cards[16].text
    assert staff_cards[17].text == u'Similarity Check', staff_cards[17].text
    assert staff_cards[18].text == u'Title And Abstract', staff_cards[18].text
    author_cards_text = [x.text for x in author_cards]
    assert u'Changes For Author' not in author_cards_text, author_cards_text
    assert u'Response to Reviewers' not in author_cards_text, author_cards_text
    assert u'Reviewer Report' not in author_cards_text, author_cards_text

    # APERTA-5513 AC 3
    author_cards[10].click()
    author_cards[11].click()
    self._get(self._add_button_overlay).click()
    time.sleep(2)
    # Check if there
    return self

  def count_cards_first_column(self):
    """Count the cards in the first column"""
    return len(self._gets(self._first_column_cards))

  def remove_last_task(self):
    """
    Remove the last task from the first column
    This test the removal process and is used for housekeeping
    """
    cards = self._gets(self._first_column_cards)
    last_card = cards[-1]
    # TODO: Find how to reach delete screen
    remove = last_card.find_element_by_xpath('//div/span')
    remove.click()
    time.sleep(10)
    return self

  def validate_confirm_delete_styles(self):
    """
    Styles validation for delete card
    This is not used until finding a way to automate reaching this place
    """
    remove_title = self._get(self._remove_confirmation_title)
    assert remove_title.text == "You're about to delete this card forever."
    self.validate_application_title_style(remove_title)
    remove_subtitle = self._get(self._remove_confirmation_subtitle)
    assert remove_subtitle.text == "Are you sure?"
    assert remove_subtitle.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    assert APPLICATION_TYPEFACE in remove_subtitle.value_of_css_property('font-family')
    assert remove_subtitle.value_of_css_property('font-size') == '30px'
    assert remove_subtitle.value_of_css_property('font-weight') == '500'
    remove_yes = self._get(self._remove_confirmation_title)
    self.validate_primary_big_green_button_style(remove_yes)
    assert remove_yes.text == "Yes, Delete this Card"
    remove_cancel = self._get(self._remove_confirmation_subtitle)
    assert remove_cancel.text == "cancel"
    assert remove_cancel.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert APPLICATION_TYPEFACE in remove_cancel.value_of_css_property('font-family')
    assert remove_cancel.value_of_css_property('font-size') == '14px'

  def add_invite_editor_card(self):
    """Add invite editor card"""
    author_col, staff_col = self._gets(self._add_card_overlay_columns)
    staff_cards = staff_col.find_elements_by_tag_name('label')
    assert staff_cards[7].text == 'Invite Academic Editor', staff_cards[7].text
    staff_cards[7].click()
    self._get(self._add_button_overlay).click()
    time.sleep(2)

  def add_card(self, card_title):
    """
    Add a card
    :card_title: Title of the card.
    :return: None
    """
    self.click_add_new_card()
    card_types = self._gets(self._card_types)
    for card in card_types:
      if card.text == card_title:
        card.click()
        break
    else:
      raise ElementDoesNotExistAssertionError('No such card: {0}'.format(card_title))
    div_buttons = self._get(self._div_buttons)
    div_buttons.find_element_by_class_name('button-primary').click()
    time.sleep(2)
    return None

  def complete_card(self, card_name):
    """
    On a given card, check complete and then close
    Assumes you have already opened card
    :param card_name: name of card to complete
    :return void function
    """
    base_card = BaseCard(self._driver)
    if card_name == 'Register Decision':
      # Complete decision data before mark close
      register_decision_card = RegisterDecisionCard(self._driver)
      register_decision_card.register_decision('Major Revision')
    elif card_name == 'Initial Decision':
      initial_decision_card = InitialDecisionCard(self._driver)
      time.sleep(2)
      id_state = initial_decision_card.execute_decision(choice='invite')
      logging.info('Executed initial decision of {0}'.format(id_state))
    else:
      completed = base_card._get(base_card._completed_check)
      if not completed.is_selected():
        completed.click()
      base_card._get(base_card._close_button).click()
      time.sleep(1)

  def set_editable(self):
    """
    Click the editable checkbox of the workflow page
    :return: void function
    """
    editable_checkbox = self._get(self._editable_checkbox)
    editable_checkbox.click()

  def page_ready(self):
    """
    Validate the page is loaded - use to validate page is ready for test
    :return: Void Function
    """
    self._wait_for_element(self._get(self._add_new_card_button))
