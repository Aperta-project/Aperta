#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Paper Editor Page. Validates global and dynamic elements and their styles
"""

import time
import pdb

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
    self._type_paragraph = (By.XPATH, './/select/option[1]')
    self._type_heading1 = (By.XPATH, './/select/option[2]')
    self._type_heading2 = (By.XPATH, './/select/option[3]')
    self._type_heading3 = (By.XPATH, './/select/option[4]')
    self._type_preformatted = (By.XPATH, './/select/option[5]')
    self._type_blockquote = (By.XPATH, './/select/option[6]')
    self._bold_icon = (By.CLASS_NAME, 'fa-bold')
    self._italic_icon = (By.CLASS_NAME, 'fa-italic')
    self._link_icon = (By.CLASS_NAME, 'fa-link')
    self._superscript_icon = (By.CLASS_NAME, 'fa-superscript')
    self._subscript_icon = (By.CLASS_NAME, 'fa-subscript')
    self._sc_icon = (By.XPATH, ".//div[contains(@class, 'annotations')]/a[6]/span")
    self._image_icon = (By.XPATH, ".//div[contains(@class, 'insert')]/a/i")
    self._table_icon = (By.CLASS_NAME, 'fa-table')
    self._book_icon = (By.CLASS_NAME, 'fa-book')
    self._pi_icon = (By.XPATH, ".//div[contains(@class, 'insert')]/a[4]")
    self._cite_icon = (By.CSS_SELECTOR, 'div.dropdown-toggle')
    self._unlock_icon = (By.CLASS_NAME, 'fa-unlock')
    self._lock_icon = (By.CLASS_NAME, 'fa-lock')
    self._diff_div = (By.CSS_SELECTOR, 'div.html-diff')



  # POM Actions
  def validate_page_elements_styles_functions(self, username=''):
    ##title = self._get(self._paper_tracker_title)
    self._get(self._collaborators_link)
    self._get(self._downloads_link)
    self._get(self._recent_activity)
    self._get(self._discussion_link)
    self._get(self._workflow_link)
    self._get(self._more_link) 
    # Check menu icons
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
    self._get(self._unlock_icon)
    # Test version button
    version_btn = self._get(self._version_link)
    version_btn.click()
    self._get(self._diff_div)
    bar_items = self._gets(self._bar_items)
    assert 'Now viewing:' in bar_items[0].text
    assert 'Compare With:' in bar_items[1].text
    version_btn.click()
    collaborator_btn = self._get(self._collaborators_link)
    collaborator_btn.click()
    add_collaborators = self._get(self._add_collaborators_label)
    assert 'Add Collaborators' in add_collaborators.text
    add_collaborators.click()
    self._get(self._add_collaborators_modal)
    add_collaborator_header = self._get(self._add_collaborators_modal_header)
    assert "Who can collaborate on this manuscript?" == add_collaborator_header.text
    #self.validate_application_h1_style(add_collaborator_header)
    self.validate_modal_title_style(add_collaborator_header)
    assert ("Select people to collaborate with on this paper. Collaborators can edit the "
            "paper, will be notified about edits on the paper, and can participate in the "
            "discussion about this paper." == self._get(
              self._add_collaborators_modal_support_text).text)
    self._get(self._add_collaborators_modal_support_select)
    cancel = self._get(self._add_collaborators_modal_cancel)
    self.validate_default_link_style(cancel)
    save = self._get(self._add_collaborators_modal_save)
    #self.validate_small_green_backed_button_style(save)
    self.validate_green_backed_button_style(save)
    
    