#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Common methods for all cards (workflow view) that are inherited by specific card instances
"""
import logging
import time

from loremipsum import generate_paragraph
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.CustomException import ElementDoesNotExistAssertionError, ElementExistsAssertionError
from Base.PostgreSQL import PgSQL
from Base.Resources import creator_login1, creator_login2, creator_login3, creator_login4, \
    creator_login5, internal_editor_login, staff_admin_login, super_admin_login, prod_staff_login, \
    pub_svcs_login, cover_editor_login, handling_editor_login, academic_editor_login
from frontend.Pages.authenticated_page import AuthenticatedPage, application_typeface, aperta_green

__author__ = 'sbassi@plos.org'


class BaseCard(AuthenticatedPage):
  """
  Common elements shared between cards. Cards are the view available from the Workflow page.
  """

  def __init__(self, driver):
    super(BaseCard, self).__init__(driver)

    # Common element for all cards
    self._header_author = (By.CLASS_NAME, 'paper-creator')
    self._header_manuscript_id = (By.CLASS_NAME, 'paper-manuscript-id')
    self._header_paper_type = (By.CLASS_NAME, 'paper-type')
    self._header_paper_state = (By.CLASS_NAME, 'paper-publishing-state')
    self._header_title_link = (By.CSS_SELECTOR, 'a.task-overlay-paper-title')
    self._manuscript_icon = (By.CLASS_NAME, 'manuscript-icon')
    self._close_button = (By.CSS_SELECTOR, 'a.overlay-close-button')
    self._card_heading = (By.CSS_SELECTOR, 'h1.overlay-body-title')

    self._notepad_textarea = (By.CSS_SELECTOR, 'textarea.notepad')
    self._notepad_toggle_icon = (
        By.XPATH, '//span[contains(text(), "Your notepad")]/preceding-sibling::i')

    self._discussion_div = (By.CLASS_NAME, 'overlay-discussion-board')
    self._add_comment = (By.CLASS_NAME, 'new-comment-field')
    self._following_label = (By.CLASS_NAME, 'participant-selector-label')
    self._add_participant_btn = (By.CLASS_NAME, 'add-participant-button')
    self._message_comment = (By.CLASS_NAME, 'message-comment')
    self._completion_button = (By.CSS_SELECTOR, 'button.task-completed')
    self._bottom_close_button = (By.CSS_SELECTOR, 'footer.overlay-footer > a')
    # Versioning locators - only applicable to metadata cards
    self._versioned_metadata_div = (By.CLASS_NAME, 'versioned-metadata-version')
    self._versioned_metadata_version_string = (By.CLASS_NAME, 'versioned-metadata-version-string')

    # Error message associated with form validation
    self._error_msg = (By.CLASS_NAME, 'error-message')

  # Common actions for all cards
  def click_close_button_bottom(self):
    """Click close button on bottom"""
    self._get(self._bottom_close_button).click()
    return self

  def click_completion_button(self):
    """Click completed checkbox"""
    self._get(self._completion_button).click()

  def completed_state(self):
    """
    Returns the selected state of the card completed button as a boolean
    Note that there is a styling difference for this text, depending on context, so doing a case
      independent comparison
    :return boolean True if completed
    """
    time.sleep(.5)
    btn_label = self._get(self._completion_button).text
    if btn_label.lower() == 'i am done with this task':
      return False
    elif btn_label.lower() == 'make changes to this task':
      return True
    else:
      raise ValueError('Completed button in unexpected state {0}'.format(btn_label))

  def click_close_button(self):
    """Click close button"""
    self._get(self._close_button).click()
    return self

  def notepad_present(self):
    """Check if notepad element is present"""
    try:
      self._get(self._notepad_textarea)
      return True
    except ElementDoesNotExistAssertionError:
      return False

  def get_text_notepad(self):
    """Get text in the textarea space in the notepad element"""
    # Give some time for text to load
    time.sleep(2)
    return self._get(self._notepad_textarea).get_attribute('value')

  def insert_text_notepad(self, text, clear=True):
    """Insert text in the textarea space in the notepad element"""
    if clear:
      self._get(self._notepad_textarea).clear()
    self._get(self._notepad_textarea).send_keys(text)
    # Insert a wait time so it can be saved
    time.sleep(3)
    return self

  def insert_text_discussion(self, text, clear=True):
    """Insert text in the textarea space as comment"""
    discussion_text_area = self._get(self._discussion_div).find_element_by_tag_name('textarea')
    if clear:
      discussion_text_area.clear()
    discussion_text_area.send_keys(text)
    # Insert a wait time so it can be saved
    time.sleep(3)

  def is_notepad_icon_open(self):
    """Check if notepad icon is in open position"""
    glyph_type = self._get(self._notepad_toggle_icon).get_attribute('class').split(" ")[1]
    if glyph_type == 'glyphicon-triangle-bottom':
      return True
    else:
      return False

  def toggle_notepad_icon(self):
    """Click on the notepad open/close icon"""
    self._get(self._notepad_toggle_icon).click()
    return self

  def validate_card_header(self, short_doi):
    """
    Validate the card heading header style
    :param short_doi: The short doi for the paper under examination
    :return: void function
    """
    paper_tuple = PgSQL().query('SELECT papers.journal_id, papers.doi, '
                                'papers.paper_type, papers.publishing_state, papers.title '
                                'FROM papers WHERE papers.short_doi=%s;', (short_doi,))[0]
    journal_id, doi, paper_type, status, title = paper_tuple[0], paper_tuple[1], paper_tuple[2], \
                                                 paper_tuple[3], paper_tuple[4]
    paper_id = self.get_paper_id_from_short_doi(short_doi)
    manuscript_id = doi.split('journal.')[1]
    status = status.replace('_', ' ').capitalize()
    role_id = PgSQL().query('SELECT id FROM roles '
                            'WHERE name=\'Creator\' AND journal_id=%s;', (journal_id,))[0][0]
    name_tuple = PgSQL().query('SELECT users.first_name, users.last_name '
                               'FROM users JOIN assignments '
                               'ON users.id = assignments.user_id '
                               'WHERE role_id = %s '
                               'AND assigned_to_type=\'Paper\' '
                               'AND assigned_to_id = %s;', (role_id, paper_id))[0]
    full_name = ' '.join([name_tuple[0], name_tuple[1]])
    logging.info('{0}'.format(full_name))
    # Validate Content
    html_header_author = self._get(self._header_author)
    author_match = self.compare_unicode(html_header_author.text, full_name)
    assert author_match, '{0} != {1}'.format(html_header_author.text, full_name)
    html_header_msid = self._get(self._header_manuscript_id)
    assert html_header_msid.text == manuscript_id, u'{0} != {1}'.format(html_header_msid.text,
                                                                        manuscript_id)
    html_header_paper_type = self._get(self._header_paper_type)
    assert html_header_paper_type.text == paper_type, u'{0} != ' \
                                                      u'{1}'.format(html_header_paper_type.text,
                                                                    paper_type)
    html_header_state = self._get(self._header_paper_state)
    assert html_header_state.text == status, u'{0} != {1}'.format(html_header_state.text, status)
    html_header_title = self._get(self._header_title_link)

    self.compare_unicode(html_header_title.text, title)
    # Validate Styles
    assert application_typeface in html_header_author.value_of_css_property('font-family'), \
        html_header_author.value_of_css_property('font-family')
    assert application_typeface in html_header_msid.value_of_css_property('font-family'), \
        html_header_msid.value_of_css_property('font-family')
    assert application_typeface in html_header_paper_type.value_of_css_property('font-family'), \
        html_header_paper_type.value_of_css_property('font-family')
    assert application_typeface in html_header_state.value_of_css_property('font-family'), \
        html_header_state.value_of_css_property('font-family')
    assert application_typeface in html_header_title.value_of_css_property('font-family'), \
        html_header_title.value_of_css_property('font-family')
    # APERTA-6497
    # assert html_header_title.value_of_css_property('font-size') == '18px', \
    #    html_header_title.value_of_css_property('font-size')
    assert html_header_title.value_of_css_property('color') == aperta_green, \
        paper_id.value_of_css_property('color')
    # APERTA-6497
    # assert html_header_title.value_of_css_property('line-height') == '23px', \
    #    html_header_title.value_of_css_property('line-height')

  @staticmethod
  def validate_plus_style(plus):
    """
    Ensure consistency in rendering the plus (+) section headings across the all cards
    # TODO: Validate with the result of #103123812
    """
    assert application_typeface in plus.value_of_css_property('font-family'), \
        plus.value_of_css_property('font-family')
    # Nota Bene: The size of this element recently changed (20170104). Checked with SebT - OK
    assert plus.value_of_css_property('font-size') == '24px', \
        plus.value_of_css_property('font-size')
    assert plus.value_of_css_property('height') == '21px', plus.value_of_css_property('height')
    assert plus.value_of_css_property('width') == '21px', plus.value_of_css_property('width')
    assert plus.value_of_css_property('line-height') == '20px', \
        plus.value_of_css_property('line-height')
    assert plus.value_of_css_property('color') == aperta_green, plus.value_of_css_property('color')
    assert plus.value_of_css_property('background-color') == 'rgba(255, 255, 255, 1)', \
        plus.value_of_css_property('background-color')
    assert plus.text == '+', plus.text

  def validate_common_elements_styles(self, short_doi):
    """
    Validate styles from elements common to all cards
    :param short_doi: short_doi of paper - needed to validate the card header elements
    :return void function
    """
    self._wait_for_element(self._get(self._header_title_link))
    self._get(self._header_title_link)
    self.validate_card_header(short_doi)
    # Close btn
    close_btn = self._get(self._close_button)
    self.validate_secondary_big_green_button_style(close_btn)
    discussion_div = self._get(self._discussion_div)
    discussion_title = discussion_div.find_element_by_tag_name('h2')
    assert discussion_title.text == 'Discussion', discussion_title.text
    # https://developer.plos.org/jira/browse/APERTA-2918
    # self.validate_application_h2_style(discussion_title)
    # Text area before clicking on it
    discussion_text_area = discussion_div.find_element_by_tag_name('textarea')
    assert discussion_text_area.get_attribute('placeholder') == 'Type your message here'
    # Enter into the textarea (can't use click since it is not working on CI)
    self._driver.execute_script("$('.new-comment-field').focus().focus();")
    time.sleep(1)
    discussion_div = self._iget(self._discussion_div)
    post_btn = discussion_div.find_element_by_tag_name('button')
    assert post_btn.text == 'POST MESSAGE', post_btn.text
    self.validate_secondary_big_green_button_style(post_btn)
    cancel_lnk = discussion_div.find_element_by_tag_name('a')
    assert cancel_lnk.text == 'Cancel', cancel_lnk.text
    self.validate_default_link_style(cancel_lnk)
    # Enter some text
    expected_text = generate_paragraph()[2]
    self.insert_text_discussion(expected_text)
    post_btn.click()
    time.sleep(1)
    # Check that the entered text is there
    message_comment = self._get(self._message_comment)
    assert expected_text in message_comment.text, (expected_text, message_comment.text)
    # Check footer
    following_label = self._get(self._following_label)
    assert following_label.text == 'Following:', following_label.text
    self._wait_for_element(self._get(self._add_participant_btn))
    add_participant_btn = self._get(self._add_participant_btn)
    self.validate_plus_style(add_participant_btn)
    bottom_close_btn = self._get(self._bottom_close_button)
    self.validate_secondary_big_green_button_style(bottom_close_btn)

  def is_versioned_view(self):
    """
    Evaluate whether the card view is a versioned view
    :return: True if versioned view of card, False otherwise
    """
    try:
      christalmighty = self.get(self._versioned_metadata_div)
    except ElementDoesNotExistAssertionError:
      logging.info('No versioned div found - not a versioned view')
      return False

    assert christalmighty.text == 'Viewing', christalmighty.text
    return True

  def extract_current_view_version(self):
    """
    Returns the currently viewed version for a given metadata card
    :return: Version string
    """
    return self.get(self._versioned_metadata_version_string).text

  def card_ready(self):
    """
    Used to validate the card is ready to be interacted with.
    :return: Void function
    """
    self._wait_for_element(self._get(self._completion_button))
