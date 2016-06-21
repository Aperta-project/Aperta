#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Common methods for all cards (workflow view) that are inherited by specific card instances
"""
import logging
import re
import time

from loremipsum import generate_paragraph
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.CustomException import ElementDoesNotExistAssertionError, ElementExistsAssertionError
from Base.PostgreSQL import PgSQL
from Base.Resources import creator_login1, creator_login2, creator_login3, creator_login4, \
    creator_login5, internal_editor_login, staff_admin_login, super_admin_login, prod_staff_login, \
    pub_svcs_login, cover_editor_login, handling_editor_login, academic_editor_login
from frontend.Pages.authenticated_page import AuthenticatedPage, application_typeface, tahi_green

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
    self._notepad_toggle_icon = (By.XPATH,
      "//span[contains(text(), 'Your notepad')]/preceding-sibling::i")

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
    self._invite_text = (By.CSS_SELECTOR, 'div.invite-editors label')
    self._invite_box = (By.ID, 'invitation-recipient')
    self._compose_invite_button = (By.CLASS_NAME,'compose-invite-button')
    # The invite table is shared between the invite ae and invite reviewer cards
    self._invitees_table = (By.CLASS_NAME, 'invitees')
    # There can be an arbitrary number of invitees, but once one is accepted, all others are
    #   revoked - we retain information about revoked invitations.
    self._invitee_listing = (By.CSS_SELECTOR, 'tr.invitation')
    # the following locators assume they will be searched for by find element within the scope of
    #   the above, enclosing div
    self._invitee_avatar = (By.CSS_SELECTOR, 'img.invitee-thumbnail')
    self._invitee_full_name = (By.CSS_SELECTOR, 'span.invitee-full-name')
    self._invitee_updated_at = (By.CSS_SELECTOR, 'span.invitation-updated-at')
    self._invitee_state = (By.CSS_SELECTOR, 'span.invitation-state')
    self._invitee_revoke = (By.CSS_SELECTOR, 'span.invite-remove')


  # Common actions for all cards
  def click_task_completed_checkbox(self):
    """Click task completed checkbox"""
    self._get(self._completed_check).click()
    return self

  def click_close_button_bottom(self):
    """Click close button on bottom"""
    self._get(self._bottom_close_button).click()
    return self

  def click_completion_button(self):
    """Click completed checkbox"""
    self._get(self._completion_button).click()

  def completed_state(self):
    """Returns the selected state of the card completed button as a boolean"""
    time.sleep(.5)
    btn_label = self._get(self._completion_button).text
    if btn_label == 'I am done with this task':
      return False
    elif btn_label == 'Make changes to this task':
      return True
    else:
      raise ValueError('Completed button in unexpected state {0}'.format(btn_label))

  def click_completed_checkbox(self):
    """Click completed checkbox"""
    self._get(self._completed_check).click()

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

  def normalize_spaces(self, text):
    """
    Helper method to leave strings with only one space between each word
    Used for string comparison when at least one string cames from an HTML document
    :text: string
    :return: string
    """
    text = text.strip()
    return re.sub(r'\s+', ' ', text)

  def toggle_notepad_icon(self):
    """Click on the notepad open/close icon"""
    self._get(self._notepad_toggle_icon).click()
    return self

  def validate_card_header(self, paper_id):
    """
    Validate the card heading header style
    """
    paper_tuple = PgSQL().query('SELECT papers.journal_id, papers.doi, '
                                'papers.paper_type, papers.publishing_state, papers.title '
                                'FROM papers WHERE papers.id=%s;', (paper_id,))[0]
    journal_id, doi, paper_type, status, title = paper_tuple[0], paper_tuple[1], paper_tuple[2], \
                                                 paper_tuple[3], paper_tuple[4]
    manuscript_id = doi.split('journal.')[1]
    status = status.replace('_', ' ').capitalize()
    logging.info('{0}'.format(status))
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
    assert html_header_author.text == full_name, '{0} != {1}'.format(html_header_author.text,
                                                                     full_name)
    html_header_msid = self._get(self._header_manuscript_id)
    assert html_header_msid.text == manuscript_id, '{0} != {1}'.format(html_header_msid.text,
                                                                       manuscript_id)
    html_header_paper_type = self._get(self._header_paper_type)
    assert html_header_paper_type.text == paper_type, '{0} != ' \
                                                      '{1}'.format(html_header_paper_type.text,
                                                                   paper_type)
    html_header_state = self._get(self._header_paper_state)
    assert html_header_state.text == status, '{0} != {1}'.format(html_header_state.text, status)
    html_header_title = self._get(self._header_title_link)
    if isinstance(html_header_title.text, unicode) and isinstance(title, unicode):
      # Split both to eliminate differences in whitespace
      html_header_title_text = html_header_title.text.split()
      title = title.split()
      assert html_header_title_text == title, \
        'Title in page: {0} != Title in DB: {1}'.format(html_header_title_text, title)
    elif isinstance(html_header_title.text, unicode) and not isinstance(title, unicode):
      html_header_title_text = self.normalize_spaces(html_header_title.text).split()
      title = self.normalize_spaces(title.decode('utf-8')).split()
      assert html_header_title_text == title, \
        'Title in page: {0} != Title in DB: {1}'.decode('utf-8').format(html_header_title_text,
          title)
    elif not isinstance(html_header_title.text, unicode) and isinstance(title, unicode):
      html_header_title_text = self.normalize_spaces(
        html_header_title.text.decode('utf-8')).split()
      title = self.normalize_spaces(title).split()
      assert html_header_title_text == title, \
        'Title in page: {0} != Title in DB: {1}'.decode('utf-8').format(
          html_header_title_text, title
          )
    else:
      html_header_title_text = self.normalize_spaces(html_header_title.text.decode('utf-8')).split()
      title = self.normalize_spaces(title.decode('utf-8')).split()
      assert html_header_title_text == title, \
        'Title in page: {0} != Title in DB: {1}'.decode('utf-8').format(
          html_header_title_text, title
          )
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
    assert html_header_title.value_of_css_property('color') == tahi_green, \
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
    assert application_typeface in plus.value_of_css_property('font-family')
    assert plus.value_of_css_property('font-size') == '32px'
    assert plus.value_of_css_property('height') == '25px'
    assert plus.value_of_css_property('width') == '25px'
    assert plus.value_of_css_property('line-height') == '20px'
    assert plus.value_of_css_property('color') == tahi_green
    assert plus.value_of_css_property('background-color') == 'rgba(255, 255, 255, 1)'
    assert plus.text == '+', plus.text

  def validate_common_elements_styles(self, paper_id):
    """
    Validate styles from elements common to all cards
    :param paper_id: id of paper - needed to validate the card header elements
    :return void function
    """
    self._get(self._header_title_link)
    self.validate_card_header(paper_id)
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
    assert post_btn.text == 'POST MESSAGE'
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
    add_participant_btn = self._get(self._add_participant_btn)
    self.validate_plus_style(add_participant_btn)
    bottom_close_btn = self._get(self._bottom_close_button)
    self.validate_secondary_big_green_button_style(bottom_close_btn)

  def is_versioned_view(self):
    """
    Evaluate whether the card view is a versioned view
    :return: True if versioned view of card, False otherwise
    """
    if self.get(self._versioned_metadata_div):
      assert self.get(self._versioned_metadata_div).text == 'Viewing', self.get(self._versioned_metadata_div).text
      return True
    else:
      return False

  def extract_current_view_version(self):
    """
    Returns the currently viewed version for a given metadata card
    :return: Version string
    """
    return self.get(self._versioned_metadata_version_string).text

  def revoke_invitee(self, invitee, role):
    """
    A method to revoke an invitation for a user
    :param invitee: The user with the invite to revoke
    :param role: The role whose invitation you want to revoke
    :return: void function
    """
    invited = self._gets(self._invitee_listing)
    for invitation in invited:
      pagefullname = invitation.find_element(*self._invitee_full_name)
      revoke = invitation.find_element(*self._invitee_revoke)
      logging.info('Checking for match between invitee to be revoked: {0} and '
                   'invitation listing {1}'.format(invitee['name'], pagefullname.text))
      if invitee['name'] in pagefullname.text:
        logging.info('Removing role {0} for {1}'.format(role, invitee['name']))
        revoke.click()
        time.sleep(5)
    self._validate_invitation_revocation(invitee, role)

  def validate_invitation(self, invitee, role):
    """
    a method to validate the invitation for a role for a user
    :param invitee: person for whom the invite should have been sent
    :param role: role whose invite should have been extended for the assignee
    :return: void function
    """
    invited = self._gets(self._invitee_listing)
    for invitation in invited:
      pagefullname = invitation.find_element(*self._invitee_full_name)
      logging.info('Checking invitee ({0}) for match among invitees'.format(invitee['name']))
      if invitee['name'] in pagefullname.text:
        match = True
      else:
        continue
      if not match:
        raise ElementDoesNotExistAssertionError('No Invitation found for {0} and '
                                                '{1}'.format(invitee['name'], role))

  def _validate_invitation_revocation(self, invitee, role):
    """
    an internal method to validate the revocation of an invite for a role for a user
    :param invitee: person for whom the invite should have been revoked
    :param role: role whose invite should have been revoked for the assignee
    :return: void function
    """
    invited = self._gets(self._invitee_listing)
    for invitation in invited:
      pagefullname = invitation.find_element(*self._invitee_full_name)
      logging.info('Checking invitee ({0}) for match among remaining '
                   'invitees'.format(invitee['name']))
      if invitee['name'] in pagefullname.text:
        raise ElementExistsAssertionError('Invitation found for {0} and {1} - should have been '
                                          'revoked'.format(invitee['name'], role))
