#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Paper Editor Page. Validates global and dynamic elements and their styles
"""

import time

from selenium.webdriver.common.by import By
from authenticated_page import AuthenticatedPage, application_typeface, manuscript_typeface

__author__ = 'sbassi@plos.org'


class PaperEditorPage(AuthenticatedPage):
  """
  Model an aperta paper editor page
  """
  def __init__(self, driver, url_suffix='/'):
    super(PaperEditorPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    self._paper_tracker_title = (By.CLASS_NAME, 'paper-tracker-message')
    self._paper_tracker_table_submit_date_th = (By.XPATH, '//th[4]')
    self._undo_icon = (By.CLASS_NAME, 'fa-undo')
    self._repeat_icon = (By.CLASS_NAME, 'fa-repeat')
    self._type_select = (By.CLASS_NAME, 'switch-type')
    self._type_paragraph = (By.CLASS_NAME, 'paragraph')
    self._type_heading1 = (By.CLASS_NAME, 'heading1')
    self._type_heading2 = (By.CLASS_NAME, 'heading2')
    self._type_heading3 = (By.CLASS_NAME, 'heading3')
    self._type_preformatted = (By.CLASS_NAME, 'preformatted')
    self._type_blockquote = (By.CLASS_NAME, 'blockquote')
    self._bold_icon = (By.CLASS_NAME, 'fa-bold')
    self._italic_icon = (By.CLASS_NAME, 'fa-italic')
    self._link_icon = (By.CLASS_NAME, 'fa-link')
    self._superscript_icon = (By.CLASS_NAME, 'fa-superscript')
    self._subscript_icon = (By.CLASS_NAME, 'fa-subscript')
    self._sc_icon = (By.CLASS_NAME, 'smallCaps')
    ## ".//div[contains(@class, 'annotations')]/a[6]/span")
    self._image_icon = (By.CSS_SELECTOR, "i.fa-image")
    self._table_icon = (By.CLASS_NAME, 'fa-table')
    self._book_icon = (By.CLASS_NAME, 'fa-book')
    self._pi_icon = (By.CLASS_NAME, 'createFormula')
    self._cite_icon = (By.CSS_SELECTOR, 'div.dropdown-toggle')
    self._diff_div = (By.CSS_SELECTOR, 'div.html-diff')
    # Download formats
    self._pdf_link = (By.XPATH, ".//div[contains(@class, 'manuscript-download-links')]/a[3]")
    self._epub_link = ((By.XPATH, ".//div[contains(@class, 'manuscript-download-links')]/a[2]"))
    self._docx_link = (By.CLASS_NAME, 'docx')

  # POM Actions
  def validate_page_elements_styles_functions(self, username=''):
    """
    Main method to validate styles and basic functions for all elements
    in the page
    """
    self._get(self._workflow_link)
    # Check editor menu icons
    self._check_editor_menu_icons()
    # Check application buttons
    self._check_version_btn_style()
    self._check_collaborator()
    self._check_download_btns()
    self._check_recent_activity()
    self._check_discussion()
    self._check_more_btn()


  def _check_editor_menu_icons(self):
    """
    Validate icons in the edit menu
    """
    self._get(self._undo_icon)
    self._get(self._repeat_icon)
    self._get(self._type_select)
    paragraph = self._get(self._type_paragraph)
    assert paragraph.get_attribute('value') == 'paragraph'
    heading1 = self._get(self._type_heading1)
    assert heading1.get_attribute('value') == 'heading1'
    heading2 = self._get(self._type_heading2)
    assert heading2.get_attribute('value') == 'heading2'
    heading3 = self._get(self._type_heading3)
    assert heading3.get_attribute('value') == 'heading3'
    preformatted = self._get(self._type_preformatted)
    assert preformatted.get_attribute('value') == 'preformatted'
    blockquote = self._get(self._type_blockquote)
    assert blockquote.get_attribute('value') == 'blockquote'
    self._get(self._bold_icon)
    self._get(self._italic_icon)
    self._get(self._link_icon)
    self._get(self._superscript_icon)
    self._get(self._subscript_icon)
    assert self._get(self._sc_icon).text == 'sc'
    self._get(self._image_icon)
    self._get(self._table_icon)
    self._get(self._book_icon)
    assert self._get(self._pi_icon).text == unicode('π2','utf-8')
    assert self._get(self._cite_icon).text == 'Cite'

  def _check_version_btn_style(self):
    """
    Test version button. This test checks styles but not funtion
    """
    version_btn = self._get(self._version_link)
    version_btn.click()
    self._get(self._diff_div)
    bar_items = self._gets(self._bar_items)
    assert 'Now viewing:' in bar_items[0].text
    assert 'Compare With:' in bar_items[1].text
    version_btn.click()

  def _check_collaborator(self):
    """
    Test collaborator modal.
    """
    collaborator_btn = self._get(self._collaborators_link)
    collaborator_btn.click()
    add_collaborators = self._get(self._add_collaborators_label)
    assert 'Add Collaborators' in add_collaborators.text
    add_collaborators.click()
    self._get(self._add_collaborators_modal)
    add_collaborator_header = self._get(self._add_collaborators_modal_header)
    assert "Who can collaborate on this manuscript?" == add_collaborator_header.text
    self.validate_modal_title_style(add_collaborator_header)
    assert ("Select people to collaborate with on this paper. Collaborators can edit the "
            "paper, will be notified about edits on the paper, and can participate in the "
            "discussion about this paper." == self._get(
              self._add_collaborators_modal_support_text).text)
    self._get(self._add_collaborators_modal_support_select)
    cancel = self._get(self._add_collaborators_modal_cancel)
    self.validate_default_link_style(cancel)
    save = self._get(self._add_collaborators_modal_save)
    self.validate_primary_big_green_button_style(save)
    close_icon_overlay = self._get(self._modal_close)
    # TODO: Change following line after bug #102078080 is solved
    assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px')
    assert application_typeface in close_icon_overlay.value_of_css_property('font-family')
    assert close_icon_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    close_icon_overlay.click()

  def _check_download_btns(self):
    """
    Check basic function and style of the downloads buttons.
    """
    downloads_link = self._get(self._downloads_link)
    downloads_link.click()
    pdf_link = self._get(self._pdf_link)
    assert 'download.pdf' in pdf_link.get_attribute('href')
    epub_link = self._get(self._epub_link)
    assert 'download.epub' in epub_link.get_attribute('href')
    assert '#' in self._get(self._docx_link).get_attribute('href')

  def _check_recent_activity(self):
    """
    Check recent activity modal styles
    """
    recent_activity = self._get(self._recent_activity)
    recent_activity.click()
    self._get(self._recent_activity_modal)
    modal_title = self._get(self._recent_activity_modal_title)
    # self.validate_application_h1_style(modal_title)
    close_icon_overlay = self._get(self._modal_close)
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
    more_btn = self._get(self._more_link)
    more_btn.click()
    self._get(self._appeal_link)
    withdraw_link = self._get(self._withdraw_link)
    withdraw_link.click()
    self._get(self._withdraw_modal)
    self._get(self._exclamation_circle)
    modal_title = self._get(self._withdraw_modal_title)
    assert 'Are you sure?' == modal_title.text
    # TODO: Style parametrized due to lack of styleguide for modals
    self.validate_modal_title_style(modal_title, '48px', line_height='52.8px',
                                    font_weight='500', color='rgba(119, 119, 119, 1)')
    withdraw_modal_text = self._get(self._withdraw_modal_text)
    # https://www.pivotaltracker.com/story/show/103864752
    # self.validate_application_ptext(withdraw_modal_text)
    assert ('Withdrawing your manuscript will withdraw it from consideration.\n'
            'Please provide your reason for withdrawing this manuscript.' in withdraw_modal_text.text)
    yes_btn = self._get(self._withdraw_modal_yes)
    assert 'YES, WITHDRAW' == yes_btn.text
    no_btn = self._get(self._withdraw_modal_no)
    assert "NO, I'M STILL WORKING" == no_btn.text
    # These link styles are not in conformance with the style guide
    # https://www.pivotaltracker.com/story/show/103858114
    # self.validate_modal_link_style(yes_btn)
    # self.validate_secondary_grey_small_button_modal_style(no_btn)
    close_icon_overlay = self._get(self._modal_close)
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
    assert self._get(self._workflow_link) if user_buttons == 7 else (len(buttons) == 6)
