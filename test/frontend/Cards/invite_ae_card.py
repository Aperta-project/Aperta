#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import re
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from Base.PostgreSQL import PgSQL
from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class InviteAECard(BaseCard):
  """
  Page Object Model for Invite AE Card
  """
  def __init__(self, driver):
    super(InviteAECard, self).__init__(driver)

    # Locators - Instance members
    self._invite_editor_text = (By.CLASS_NAME, 'invite-editor-text')
    self._send_invitation_button = (By.CLASS_NAME, 'invitation-item-action-send')
    self._rescind_button = (By.CSS_SELECTOR, 'span.invitation-item-action-text')
    self._recipient_field = (By.ID, 'invitation-recipient')
    self._compose_invitation_button = (By.CLASS_NAME, 'invitation-email-entry-button')
    self._edit_invite_heading = (By.CLASS_NAME, 'invitation-item-full-name')
    self._edit_invite_textarea = (By.CSS_SELECTOR, 'div.invitation-edit-body')
    self._edit_save_invitation_btn = (By.CLASS_NAME, 'invitation-save-button')
    self._edit_invite_text_cancel = (By.CSS_SELECTOR, 'button.cancel')
    self._edit_invite_text_save = (By.CSS_SELECTOR, 'button.invitation-save-button')
    # new action buttons
    self._invite_edit_invite_button = (By.CSS_SELECTOR, 'span.invitation-item-action-edit')
    self._invite_delete_invite_button = (By.CSS_SELECTOR, 'span.invitation-item-action-delete')
    self._invite_send_invite_button = (By.CSS_SELECTOR, 'span.invitation-item-action-send')

    self._invitees_table = (By.CLASS_NAME, 'invitees')
    # There can be an arbitrary number of invitees, but once one is accepted, all others are
    #   revoked - we retain information about revoked invitations.
    self._invitee_listing = (By.CLASS_NAME, 'invitation-item')

    # the following locators assume they will be searched for by find element within the scope of
    #   the above, enclosing div
    self._invitee_full_name = (By.CSS_SELECTOR, 'div.invitation-item-full-name')
    self._invitee_updated_at = (By.CLASS_NAME, 'invitation-item-state-and-date')
    self._invitee_state = (By.CLASS_NAME, 'invitation-item-status')
    self._reason_suggestions = (By.CLASS_NAME, 'invitation-item-decline-info')

  # POM Actions
  def invite_ae(self, user):
    """
    This method invites the user that is passed as parameter
    :user: User to send the invitation
    """
    time.sleep(.5)
    self._get(self._recipient_field).send_keys(user['email'] + Keys.ENTER)
    self._get(self._compose_invitation_button).click()
    time.sleep(1)
    self._get(self._edit_invite_text_save).click()
    time.sleep(1)
    self._get(self._invite_send_invite_button).click()
    time.sleep(1)
    self.click_completion_button()
    self.click_close_button()

  def validate_invite_ae(self, ae, title, creator, manu_id):
    """
    Invites the Academic Editor (AE) that is passed as parameter, verifying the composed email.
      Makes function and style validations.
    :param ae: user to invite as AE specified as email, or, if in system, name,
        or username
    :param title: title of the manuscript - for validation of invite content. Assumed to be unicode
    :param creator: user object of the creator of the manuscript
    :param manu_id: paper id of the manuscript
    :return void function
    """
    time.sleep(.5)
    self._get(self._recipient_field).send_keys(ae['email'] + Keys.ENTER)
    self._get(self._compose_invitation_button).click()
    time.sleep(2)

    invite_headings = self._gets(self._edit_invite_heading)
    # Since the AE is potentially off system, we can only validate email
    invite_headings_text = [x.text for x in invite_headings]
    assert any(ae['email'] in s for s in invite_headings_text), \
        '{0} not found in {1}'.format(ae['email'], invite_headings_text)
    invite_text = self._get(self._edit_invite_textarea).text
    # Always remember that our ember text always normalizes whitespaces down to one
    #  Painful lesson
    title = re.sub(r'[ \t\f\v]+', ' ', title)
    # and need to scrub latin-1 non-breaking spaces
    title = re.sub(u'\xa0', u' ', title)
    assert title in invite_text, \
        title + '\nNot found in \n' + invite_text
    assert 'PLOS Wombat' in invite_text, invite_text
    assert '***************** CONFIDENTIAL *****************' in invite_text, invite_text
    creator_fn, creator_ln = creator['name'].split(' ')[0], creator['name'].split(' ')[1]
    assert u'{0}, {1}'.format(creator_ln, creator_fn) in invite_text, invite_text
    abstract = PgSQL().query('SELECT abstract FROM papers WHERE id=%s;', (manu_id,))[0][0]
    if abstract is not None:
      # strip html, and remove whitespace
      # NOTA BENE: BeautifulSoup4 inherently handles str to unicode conversion
      abstract = self.get_text(abstract).strip()
    if abstract is not None:
      # Always remember that our ember text always normalizes whitespaces down to one
      #  Painful lesson
      abstract = re.sub(r'[ \t\f\v]+', ' ', abstract)
      # It also removes trailing spaces
      abstract = re.sub(r'[ \t\f\v]+\n', r'\n', abstract)
      # and need to scrub latin-1 non-breaking spaces
      abstract = re.sub(u'\xa0', u' ', abstract)
      assert abstract in invite_text, abstract + '\nNot equal to\n' + invite_text
    else:
      assert 'Abstract is not available' in invite_text, invite_text
    self._get(self._edit_save_invitation_btn).click()
    time.sleep(1)
    invitees = self._gets(self._invitee_listing)
    assert any(ae['name'] in s for s in [x.text for x in invitees]), \
        '{0} not found in {1}'.format(ae['name'], [x.text for x in invitees])
    self._get(self._invitee_updated_at)
    # Make the actual invitation
    self._get(self._send_invitation_button).click()
    time.sleep(2)
    assert any('Invited' in s for s in [x.text for x in invitees]), \
        'Invited not found in {0}'.format([x.text for x in invitees])
    self._gets(self._rescind_button)

  def validate_ae_response(self, ae, response, reason='N/A', suggestions='N/A'):
    """
    This method invites the Academic Editor (AE) that is passed as parameter, verifying
      the composed email. It then checks the table of invited AE.
    :param ae: user to invite as reviewer specified as email, or, if in system, name,
        or username
    :param response: The reviewers response to the invitation
    :return void function
    """
    time.sleep(2)
    invitee = self._get(self._invitee_listing)
    pagefullname = False
    count = 0
    while not pagefullname:
      pagefullname = invitee.find_element(*self._invitee_full_name)
      count += 1
      time.sleep(.5)
      if count > 60:
        raise(StandardError, 'Full name not present, aborting')
    assert ae['name'] in pagefullname.text
    status = invitee.find_element(*self._invitee_state)
    assert response in ['Accept', 'Decline'], response
    if response == 'Accept':
      assert 'Accepted' in status.text, status.text
    elif response == 'Decline':
      # Need to extend box to display text
      assert 'Decline' in status.text, status.text
      status.click()
      reason_suggestions = self._get(self._reason_suggestions).text
      reason_suggestions = self.normalize_spaces(reason_suggestions)
      assert reason in reason_suggestions, u'{0} not in {1}'.format(reason, reason_suggestions)
      assert suggestions in reason_suggestions, u'{0} not in {1}'.format(reason,
                                                                         reason_suggestions)

  def check_style(self, user, paper_id):
    """
    Style check for the card
    :user: User to send the invitation
    """
    self.validate_common_elements_styles(paper_id)
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Invite Academic Editor'
    self.validate_application_title_style(card_title)
    # There is no definition of this external label style in the style guide. APERTA-7311
    #   currently, a new style validator has been implemented to match this UI
    ae_input = self._get(self._invite_box)
    assert ae_input.get_attribute('placeholder') == 'Invite editor by name or email' ,\
        ae_input.get_attribute('placeholder')
    # Button
    btn = self._get(self._compose_invitation_button)
    assert btn.text == 'COMPOSE INVITE'
    # Check disabled button
    # Style validation on disabled button is commented out due to APERTA-7684
    # self.validate_primary_big_disabled_button_style(btn)
    # Enable button to check style
    ae_input.send_keys(user['email'] + Keys.ENTER)
    ae_input.send_keys(Keys.ENTER)
    time.sleep(.5)
    self.validate_secondary_big_green_button_style(btn)
    ae_input.clear()
    return None
