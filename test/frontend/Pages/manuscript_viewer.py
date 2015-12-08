#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Paper Editor Page. Validates global and dynamic elements and their styles
NOTE: This POM will be outdated when the Paper Editor is removed.
"""

import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from authenticated_page import AuthenticatedPage, application_typeface, manuscript_typeface
from Base.Resources import affiliation, billing_data
from Base.PostgreSQL import PgSQL
from frontend.Cards.authors_card import AuthorsCard
from frontend.Cards.basecard import BaseCard
from frontend.Cards.billing_card import BillingCard
from frontend.Cards.figures_card import FiguresCard
from frontend.Cards.revise_manuscript_card import ReviseManuscriptCard

__author__ = 'sbassi@plos.org'


class ManuscriptViewerPage(AuthenticatedPage):
  """
  Model an aperta paper viewer page
  """
  def __init__(self, driver, url_suffix='/'):
    super(ManuscriptViewerPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # dashboard Link
    self._dashboard_link = (By.ID, 'nav-dashboard')
    # Main Viewer Div
    self._paper_title = (By.ID, 'paper-title')
    self._paper_tracker_title = (By.CLASS_NAME, 'paper-tracker-message')
    self._paper_tracker_table_submit_date_th = (By.XPATH, '//th[4]')
    self._card = (By.CLASS_NAME, 'card')
    self._submit_button = (By.ID, 'sidebar-submit-paper')
    # Main Toolbar items
    self._tb_versions_link = (By.ID, 'nav-versions')
    self._tb_versions_diff_div = (By.CSS_SELECTOR, 'div.html-diff')
    #self._tb_view_version = (By.TAG_NAME, 'select')
    self._tb_versions_closer = (By.CLASS_NAME, 'exit-versions')
    self._tb_collaborators_link = (By.ID, 'nav-collaborators')
    self._tb_add_collaborators_label = (By.CLASS_NAME, 'contributors-add')
    self._tb_collaborator_list_item = (By.CLASS_NAME, 'contributor')
    self._tb_downloads_link = (By.ID, 'nav-downloads')
    self._tb_dl_pdf_link = (By.XPATH, ".//div[contains(@class, 'manuscript-download-links')]/a[3]")
    self._tb_dl_epub_link = ((By.XPATH, ".//div[contains(@class, 'manuscript-download-links')]/a[2]"))
    self._tb_dl_docx_link = (By.CLASS_NAME, 'docx')
    self._tb_more_link = (By.ID, 'more-dropdown-menu')
    self._tb_more_appeal_link = (By.ID, 'nav-appeal')
    self._tb_more_withdraw_link = (By.ID, 'nav-withdraw-manuscript')
    self._tb_workflow_link = (By.ID, 'go-to-workflow')
    # Task List Items
    self._tl_manuscript_id = (By.CLASS_NAME, 'task-list-doi')
    self._tl_submit_success_msg = (By.CLASS_NAME, 'task-list')
    # Manage Collaborators Overlay
    self._add_collaborators_modal = (By.CLASS_NAME, 'show-collaborators-overlay')
    self._add_collaborators_modal_header = (By.CLASS_NAME, 'overlay-title-text')
    self._add_collaborators_modal_support_text =  (By.CLASS_NAME, 'overlay-supporting-text')
    self._add_collaborators_modal_support_select = (By.CLASS_NAME, 'collaborator-select')
    #self._add_collaborators_modal_select = (By.CLASS_NAME, 'select2-arrow')
    #self._add_collaborators_modal_select_input = (By.TAG_NAME, 'input')
    self._add_collaborators_modal_select = (By.CSS_SELECTOR, 'div.select2-container')
    ###XXXX

    self._add_collaborators_modal_cancel = (By.XPATH, "//div[@class='overlay-action-buttons']/a")
    self._add_collaborators_modal_save = (By.XPATH, "//div[@class='overlay-action-buttons']/button")
    # Withdraw Manuscript Overlay
    self._wm_modal = (By.CLASS_NAME, 'overlay--fullscreen')
    self._wm_exclamation_circle = (By.CLASS_NAME, 'fa-exclamation-circle')
    self._wm_modal_title = (By.CSS_SELECTOR, 'h1')
    self._wm_modal_text = (By.CSS_SELECTOR, 'div.overlay-body div p')
    self._wm_modal_yes = (By.XPATH, '//div[@class="pull-right"]/button[1]')
    self._wm_modal_no = (By.XPATH, '//div[@class="pull-right"]/button[2]')
    # Submit Confirmation and Submit Congratulations Overlays (full and initial submit versions)
    # The overlay close X is universal and defined in authenticated page (self._overlay_header_close)
    self._so_paper_submit_icon = (By.CLASS_NAME, 'paper-submit-icon')
    # self._so_paper_submit_title_text_submit = (By.CSS_SELECTOR, 'div.overlay-title-text-submit h1')
    # self._so_paper_submit_subhead_text_submit = (By.CSS_SELECTOR, 'div.overlay-title-text-submit + h5')
    self._so_paper_title = (By.ID, 'paper-submit-title')
    self._so_submit_confirm = (By.CLASS_NAME, 'button-submit-paper')
    self._so_submit_cancel = (By.CSS_SELECTOR, 'div.submit-action-buttons button.button-link')
    self._so_close_after_submit = (By.CLASS_NAME, 'success-close')
    # Cards
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
    # infobox
    self._question_mark_icon = (By.ID, 'submission-process-toggle')
    self._infobox = (By.ID, 'submission-process')
    self._submission_status_info = (By.ID, 'submission-state-information')

  # POM Actions
  def validate_page_elements_styles_functions(self, username=''):
    """
    Main method to validate styles and basic functions for all elements
    in the page
    """
    self._get(self._tb_workflow_link)
    # Check application buttons
    self._check_version_btn_style()
    self._check_collaborator()
    self._check_download_btns()
    self._check_recent_activity()
    self._check_discussion()
    self._check_more_btn()

  def _check_version_btn_style(self):
    """
    Test version button. This test checks styles but not funtion
    """
    version_btn = self._get(self._tb_versions_link)
    version_btn.click()
    self._get(self._tb_versions_diff_div)
    bar_items = self._gets(self._bar_items)
    print([x.text for x in bar_items])
    assert 'Now viewing:' in bar_items[1].text, bar_items[1].text
    assert 'Compare With:' in bar_items[2].text, bar_items[2].text
    self._get(self._tb_versions_closer).click()

  def get_manuscript_version(self):
    """
    Retrieves current manuscript version
    :return: String with manuscript version number
    """
    version_btn = self._get(self._tb_versions_link)
    version_btn.click()
    bar_items = self._gets(self._bar_items)
    version_number = bar_items[1].text.split('\n')[1].split()[0]
    self._get(self._tb_versions_closer).click()
    return version_number

  def get_journal_id(self):
    """
    Retrieves journal id
    :return: Int with journal_id
    """
    paper_id = self.get_paper_db_id()
    print paper_id
    journal_id = PgSQL().query('SELECT papers.journal_id FROM papers where id = %s;', (paper_id,))[0][0]
    return journal_id

  def _check_collaborator(self):
    """
    Test collaborator modal.
    """
    collaborator_btn = self._get(self._tb_collaborators_link)
    collaborator_btn.click()
    add_collaborators = self._get(self._tb_add_collaborators_label)
    assert 'Add Collaborators' in add_collaborators.text
    add_collaborators.click()
    self._get(self._add_collaborators_modal)
    add_collaborator_header = self._get(self._overlay_header_title)
    assert "Who can collaborate on this manuscript?" == add_collaborator_header.text
    # self.validate_modal_title_style(add_collaborator_header)
    assert ("Select people to collaborate with on this paper. Collaborators can edit the "
            "paper, will be notified about edits on the paper, and can participate in the "
            "discussion about this paper." == self._get(
              self._add_collaborators_modal_support_text).text)
    self._get(self._add_collaborators_modal_support_select)
    cancel = self._get(self._overlay_action_button_cancel)
    self.validate_default_link_style(cancel)
    save = self._get(self._overlay_action_button_save)
    self.validate_primary_big_green_button_style(save)
    close_icon_overlay = self._get(self._overlay_header_close)
    # TODO: Change following line after bug #102078080 is solved
    assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px')
    assert application_typeface in close_icon_overlay.value_of_css_property('font-family')
    assert close_icon_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    close_icon_overlay.click()

  def _check_download_btns(self):
    """
    Check basic function and style of the downloads buttons.
    """
    downloads_link = self._get(self._tb_downloads_link)
    downloads_link.click()
    pdf_link = self._get(self._tb_dl_pdf_link)
    assert 'download.pdf' in pdf_link.get_attribute('href')
    epub_link = self._get(self._tb_dl_epub_link)
    assert 'download.epub' in epub_link.get_attribute('href')
    assert '#' in self._get(self._tb_dl_docx_link).get_attribute('href')

  def _check_recent_activity(self):
    """
    Check recent activity modal styles
    """
    recent_activity = self._get(self._recent_activity)
    recent_activity.click()
    time.sleep(.5)
    self._get(self._recent_activity_modal)
    modal_title = self._get(self._overlay_header_title)
    #Temporary disable due to bad style
    #self.validate_application_h1_style(modal_title)
    close_icon_overlay = self._get(self._overlay_header_close)
    # TODO: Change following line after bug #102078080 is solved
    assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px')
    assert application_typeface in close_icon_overlay.value_of_css_property('font-family')
    assert close_icon_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    close_icon_overlay.click()

  def _check_discussion(self):
    """
    Check discussion modal styles
    """
    discussion_link = self._get(self._discussion_link)
    discussion_link.click()
    discussion_container = self._get(self._discussion_container)
    discussion_container_title = self._get(self._discussion_container_title)
    # Note: The following method is parametrized since we don't have a guide for modals
    self.validate_modal_title_style(discussion_container_title, '36px', '500', '39.6px')
    assert 'Discussions' in discussion_container_title.text
    discussion_create_new_btn = self._get(self._discussion_create_new_btn)
    ##self.validate_secondary_green_button_style(discussion_create_new_btn)
    ##self.validate_secondary_small_green_button_style(discussion_create_new_btn)
    self.validate_secondary_big_green_button_style(discussion_create_new_btn)
    discussion_create_new_btn.click()
    create_new_topic = self._get(self._create_new_topic)
    assert 'Create New Topic' in create_new_topic.text
    # TODO: Styles for cancel since is not in the style guide
    cancel = self._get(self._create_topic_cancel)
    assert application_typeface in cancel.value_of_css_property('font-family')
    assert cancel.value_of_css_property('font-size') == '14px'
    assert cancel.value_of_css_property('line-height') == '60px'
    assert cancel.value_of_css_property('background-color') == 'transparent'
    assert cancel.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert cancel.value_of_css_property('font-weight') == '400'
    # TODO: Styles for create_new_topic since is not in the style guide
    titles = self._gets(self._topic_title)
    assert 'Topic Title' == titles[0].text
    assert 'Message' == titles[1].text
    create_topic_btn = self._get(self._create_topic_btn)
    ##self.validate_green_backed_button_style(create_topic_btn)
    self.validate_primary_big_green_button_style(create_topic_btn)
    close_icon_overlay = self._get(self._sheet_close_x)
    # TODO: Change following line after bug #102078080 is solved
    assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px', '42px')
    assert application_typeface in close_icon_overlay.value_of_css_property('font-family')
    assert close_icon_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    close_icon_overlay.click()

  def _check_more_btn(self):
    """
    Check all options inside More button (Appeal and Withdraw).
    Note that Appeal is not implemented yet, so it is not tested.
    """
    more_btn = self._get(self._tb_more_link)
    more_btn.click()
    self._get(self._tb_more_appeal_link)
    withdraw_link = self._get(self._tb_more_withdraw_link)
    withdraw_link.click()
    self._get(self._wm_modal)
    self._get(self._wm_exclamation_circle)
    modal_title = self._get(self._wm_modal_title)
    assert 'Are you sure?' == modal_title.text
    # TODO: Style parametrized due to lack of styleguide for modals
    self.validate_modal_title_style(modal_title, '48px', line_height='52.8px',
                                    font_weight='500', color='rgba(119, 119, 119, 1)')
    withdraw_modal_text = self._get(self._wm_modal_text)
    # TODO: Leave comment out until solved. Pivotal bug#103864752
    #self.validate_application_ptext(withdraw_modal_text)
    assert ('Withdrawing your manuscript will withdraw it from consideration.\n'
            'Please provide your reason for withdrawing this manuscript.' in withdraw_modal_text.text)
    yes_btn = self._get(self._wm_modal_yes)
    assert 'YES, WITHDRAW' == yes_btn.text
    no_btn = self._get(self._wm_modal_no)
    assert "NO, I'M STILL WORKING" == no_btn.text
    self.validate_link_big_grey_button_style(yes_btn)
    # TODO: Leave comment out until solved. Pivotal bug#103858114
    #self.validate_secondary_grey_small_button_modal_style(no_btn)
    close_icon_overlay = self._get(self._overlay_header_close)
    # TODO: Change following line after bug #102078080 is solved
    assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px')
    assert application_typeface in close_icon_overlay.value_of_css_property('font-family')
    assert close_icon_overlay.value_of_css_property('color') == 'rgba(119, 119, 119, 1)'
    close_icon_overlay.click()

  def validate_roles(self, user_buttons):
    """
    Given an amount of expected item, check if they are in the top menu.
    This can be expanded as needed.
    """
    # Time needed to update page and get correct amount of items
    time.sleep(1)
    buttons = self._gets(self._control_bar_right_items)
    assert self._get(self._tb_workflow_link) if user_buttons == 8 else (len(buttons) == 7), len(buttons)

  def complete_card(self, card_name, click_override=False):
    """On a given card, check complete and then close"""
    cards = self._gets((By.CLASS_NAME, 'card-title'))
    # if card is marked as complete, leave is at is.
    if not click_override:
      for card in cards:
        card_div = card.find_element_by_xpath('../..')
        if card.text == card_name and 'card--completed' not in card_div.get_attribute('class'):
          card.find_element_by_xpath('.//ancestor::a').click()
          break
        elif card.text == card_name and 'card--completed' in card_div.get_attribute('class'):
          return None
      else:
        return None
    else:
      for card in cards:
        if card.text == card_name:
          card.find_element_by_xpath('.//ancestor::a').click()
          break
      else:
        return None

    base_card = BaseCard(self._driver)
    if card_name in ('Cover Letter', 'Figures', 'Supporting Info', 'Upload Manuscript', 'Revise Manuscript'):
      # Check completed_check status
      completed = base_card._get(base_card._completed_check)
      if not completed.is_selected():
        completed.click()
        #time.sleep(.2)
      base_card._get(base_card._close_button).click()
      time.sleep(1)
    elif card_name == 'Authors':
      # Complete authors data before mark close
      author_card = AuthorsCard(self._driver)
      author_card.edit_author(affiliation)
    elif card_name == 'Billing':
      billing = BillingCard(self._driver)
      billing.add_billing_data(billing_data)

  def get_paper_title_from_page(self):
    """
    Returns the encoded paper title as it appears on the manuscript_viewer page
    :return: paper_title
    """
    paper_title = self._get(self._paper_title).text
    print(paper_title)
    return paper_title

  def click_submit_btn(self):
    """Press the submit button"""
    self._get(self._submit_button).click()

  def confirm_submit_btn(self):
    """Confirm paper submission"""
    self._get(self._so_submit_confirm).click()

  def confirm_submit_cancel(self):
    """Cancel on confirm paper submission"""
    self._get(self._so_submit_cancel).click()

  def close_submit_overlay(self):
    """Close the submit overlay after confirm paper submission"""
    closer = self._get(self._overlay_header_close)
    closer.click()

  def click_workflow_lnk(self):
    """Click workflow button"""
    self._get(self._tb_workflow_link).click()

  def click_question_mark(self):
    """Click on the question mark to open Infobox"""
    self._get(self._question_mark_icon).click()

  def click_dashboard_link(self):
    """Click on dashboard link"""
    self._get(self._dashboard_link).click()

  def get_infobox(self):
    """Get the infobox element"""
    return self._get(self._infobox)

  def get_paper_id(self):
    """
    Returns the paper id
    """
    doi_text = self._get(self._tl_manuscript_id).text
    return doi_text.split(':')[1]

  def get_paper_db_id(self):
    """
    Returns the DB paper ID from URL
    """
    paper_url = self.get_current_url()
    paper_id = int(paper_url.split('papers/')[1])
    print('The paper DB ID is: {}'.format(paper_id))
    return paper_id

  def validate_so_overlay_elements_styles(self, type, paper_title):
    """
    :param type: full_submit, initial_submit, initial_submit_full, congrats, congrats_is, congrats_is_full
    :return:
    """
    self._get(self._overlay_header_close)
    self._so_paper_submit_title_text_submit = (By.CSS_SELECTOR, 'div.overlay-title-text-submit h1')
    self._so_paper_submit_subhead_text_submit = (By.CSS_SELECTOR, 'div.overlay-title-text-submit + h5')
    main_head = self._get(self._so_paper_submit_title_text_submit)
    subhead = self._get(self._so_paper_submit_subhead_text_submit)
    if type == 'full_submit':
      assert 'Are you sure?' in main_head.text, main_head.text
      assert 'You are about to submit the paper' in subhead.text, subhead.text
    elif type == 'congrats':
      #assert 'Congratulations' in main_head.text, main_head.text
      self._get(self._so_paper_submit_icon)
      assert "You've successfully submitted your paper!" in subhead.text, subhead.text
      self._get(self._so_submit_cancel)
    elif type == 'congrats_is':
      assert 'You have successfully submitted your manuscript for initial review. If the initial review is ' \
             'favorable, we will invite you to add some information to facilitate peer review.' in subhead.text, \
             subhead.text
    elif type == 'congrats_full':
      assert 'You have successfully submitted your manuscript. We will start the peer review process.'
    if type in ('full_submit', 'initial_submit', 'initial_submit_full'):
      manuscript_title = self._get(self._so_paper_title)
      assert paper_title in manuscript_title.text, paper_title + ' vs ' + manuscript_title.text
      self._get(self._so_submit_confirm)

  def validate_submit_success(self):
    """Ensure the successful submit message appears in the upper right corner of the manuscript viewer page"""
    success_msg = self._get(self._tl_submit_success_msg)
    assert 'This paper has been submitted.' in success_msg.text, success_msg.text

  def validate_initial_submit_success(self):
    """Ensure the final submit message does not appear on initial submit"""
    success_msg = self._get(self._tl_submit_success_msg)
    assert 'This paper has been submitted.' not in success_msg.text, success_msg.text

  def add_collaborators(self, user):
    """
    Add a collaborator
    :param user: user
    :return: None
    """
    self._get(self._tb_collaborators_link).click()
    self._get(self._tb_add_collaborators_label).click()
    time.sleep(2)
    select_div = self._get(self._add_collaborators_modal_select)
    select_div.find_element_by_tag_name('a').click()
    select_items = (By.CSS_SELECTOR, 'ul.select2-results')
    items = self._get(select_items)
    for item in items.find_elements_by_tag_name('li'):
      if item.text == user['name']:
        item.click()
        time.sleep(.5)
        break
    else:
      raise Exception("User {} not found".format(user['name']))
    time.sleep(1)
    self._get(self._add_collaborators_modal_save).click()

  def get_submission_status_info_text(self):
    """
    """
    return self._get(self._submission_status_info).text
