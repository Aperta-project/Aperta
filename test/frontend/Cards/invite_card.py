#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import re
import time
import os
import random

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from Base.PostgreSQL import PgSQL
from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class InviteCard(BaseCard):
  """
  Abstract class for Page Object Model of all types of Invite cards
  """
  def __init__(self, driver):
    super(InviteCard, self).__init__(driver)

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
    self._reason_suggestions = (By.CLASS_NAME, 'invitation-item-decline-info')

    # the following locators assume they will be searched for by find element within the scope of
    #   the above, enclosing div
    self._invitee_full_name = (By.CSS_SELECTOR, 'div.invitation-item-full-name')
    self._invitee_updated_at = (By.CLASS_NAME, 'invitation-item-state-and-date')
    self._invitee_state = (By.CLASS_NAME, 'invitation-item-status')
    self._file_attach_btn = (By.CSS_SELECTOR, 'input.add-new-attachment')
    self._replace_attachment = (By.CLASS_NAME, 'replace-attachment')

  # POM Actions
  def invite(self, user):
    """
    This method invites the user that is passed as parameter
    :user: User to send the invitation
    :return: None
    """
    self._wait_for_element(self._get(self._recipient_field))
    self._get(self._recipient_field).send_keys(user['email'] + Keys.ENTER)
    self._get(self._compose_invitation_button).click()
    self._wait_for_element(self._get(self._edit_invite_text_save))
    self._get(self._edit_invite_text_save).click()
    self._wait_for_element(self._get(self._invite_send_invite_button))
    self._get(self._invite_send_invite_button).click()
    # The problem with this next item is that it requires the button to be clickable
    # when after send, the whole invite element is in a readonly state.
    self._wait_for_element(self._get(self._rescind_button))
    self.click_close_button()

  def validate_invite(self, invitee, title, creator, ms_id):
    """
    Invites the invitee that is passed as parameter, verifying the composed email.
      Makes function and style validations.
    :param invitee: user to invite specified as email, or, if in system, name,
        or username
    :param title: title of the manuscript - for validation of invite content. Assumed to be unicode
    :param creator: user object of the creator of the manuscript
    :param attach: filename to attach to the invitation
    :param ms_id: paper id of the manuscript
    :return void function
    """
    self._wait_for_element(self._get(self._recipient_field))
    self._get(self._recipient_field).send_keys(invitee['email'] + Keys.ENTER)
    self._get(self._compose_invitation_button).click()
    time.sleep(2)
    invite_headings = self._gets(self._edit_invite_heading)
    # Since the invitee is potentially off system, we can only validate email
    invite_headings_text = [x.text for x in invite_headings]
    assert any(invitee['email'] in s for s in invite_headings_text), \
        '{0} not found in {1}'.format(invitee['email'], invite_headings_text)
    invite_text = self._get(self._edit_invite_textarea).get_attribute('innerHTML')
    invite_text = invite_text.replace('&nbsp', ' ')
    # Always remember that our ember text always normalizes whitespaces down to one
    #  Painful lesson
    title = self.normalize_spaces(title)
    assert title in invite_text, title + '\nNot found in \n' + invite_text
    assert 'PLOS Wombat' in invite_text, invite_text
    assert '***************** CONFIDENTIAL *****************' in invite_text, invite_text
    creator_fn, creator_ln = creator['name'].split(' ')[0], creator['name'].split(' ')[1]
    main_author = u'{0}, {1}'.format(creator_ln, creator_fn)
    assert main_author in invite_text, (main_author, invite_text)
    abstract = PgSQL().query('SELECT abstract FROM papers WHERE id=%s;', (ms_id,))[0][0]
    if abstract is not None:
      # Always remember that our ember text always normalizes whitespaces down to one
      #  Painful lesson
      abstract = self.normalize_spaces(abstract)
      invite_text = self.normalize_spaces(invite_text)
      assert abstract in invite_text, u'{0} not in {1}'.format(abstract, invite_text)
    else:
      assert 'Abstract is not available' in invite_text, invite_text
    # Attach a file
    sample_files = ('frontend/assets/docs/UserTest4_MS_File_2.docx',
                    'frontend/assets/imgs/plos.gif',
                    'frontend/assets/NC3Rs_ARRIVE_Guidelines_2013.pdf',
                    'frontend/assets/PRISMA_2009_checklist.doc',
                    'frontend/assets/imgs/snakebite_journal.pntd.0002302.g001.png',
                    'frontend/assets/supportingInfo/S1_File 2.xlsx'
                    )
    file_1, file_2 = random.sample(sample_files, 2)
    fn = os.path.join(os.getcwd(), file_1)
    self.attach_file(fn)
    # look for file name and replace attachment link
    self._wait_for_element(self._get(self._replace_attachment))
    attachments = self.get_attached_file_names()
    fn = fn.split('/')[-1].replace(' ', '+')
    assert fn in attachments, '{0} not in {1}'.format(fn, attachments)
    # Attach a sencond file
    fn = os.path.join(os.getcwd(), file_2)
    self.attach_file(fn)
    # Wait for file to attach
    counter = 0
    while True:
      if len(self._gets(self._replace_attachment)) == 2 or counter == 60:
        break
      counter += 1
      time.sleep(.5)
    attachments = self.get_attached_file_names()
    fn = fn.split('/')[-1].replace(' ', '+')
    assert fn in attachments, '{0} not in {1}'.format(fn, attachments)
    # Delete the second file from the attach
    self.delete_attach_file(fn)
    # Test that there is only one attach after the delete
    counter = 0
    while True:
      if len(self._gets(self._replace_attachment)) == 1 or counter == 60:
        break
      counter += 1
      time.sleep(.5)
    self._get(self._edit_save_invitation_btn).click()
    invitees = self._gets(self._invitee_listing)
    assert any(invitee['name'] in s for s in [x.text for x in invitees]), \
        '{0} not found in {1}'.format(invitee['name'], [x.text for x in invitees])
    self._get(self._invitee_updated_at)
    # Make the actual invitation
    self._get(self._send_invitation_button).click()
    # This wait is needed for the invite text to appear
    time.sleep(2)
    invitees = self._gets(self._invitee_listing)
    assert any('Invited' in s for s in [x.text for x in invitees]), \
        'Invited not found in {0}'.format([x.text for x in invitees])
    self._gets(self._rescind_button)

  def validate_response(self, invitee, response, reason='N/A', suggestions='N/A'):
    """
    This method invites the invitee that is passed as parameter, verifying
      the composed email. It then checks the table of invited users.
    :param invitee: user to invite specified as email, or, if in system, name,
        or username
    :param response: The response to the invitation
    :return void function
    """
    self._wait_for_element(self._get(self._invitee_listing))
    invitee_element = self._get(self._invitee_listing)
    pagefullname = False
    count = 0
    while not pagefullname:
      pagefullname = invitee_element.find_element(*self._invitee_full_name)
      count += 1
      time.sleep(.5)
      if count > 60:
        raise(StandardError, 'Full name not present, aborting')
    assert invitee['name'] in pagefullname.text
    status = invitee_element.find_element(*self._invitee_state)
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

  def validate_card_elements_styles(self, user, card_type, paper_id):
    """
    Style check for the card
    :param user: User (AE or Reviewer) to send the invitation
    :return None
    """
    self.validate_common_elements_styles(paper_id)
    # There is no definition of this external label style in the style guide. APERTA-7311
    #   currently, a new style validator has been implemented to match this UI
    user_input = self._get(self._invite_box)
    card_title = self._get(self._card_heading)
    if card_type == 'reviewer':
      assert card_title.text == 'Invite Reviewers', card_title.text
      assert user_input.get_attribute('placeholder') == 'Invite reviewer by name or email' ,\
        user_input.get_attribute('placeholder')
    elif card_type == 'ae':
      assert card_title.text == 'Invite Academic Editor', card_title.text
      assert user_input.get_attribute('placeholder') == 'Invite editor by name or email' ,\
        user_input.get_attribute('placeholder')
    self.validate_application_title_style(card_title)
    # Button
    btn = self._get(self._compose_invitation_button)
    assert btn.text == 'COMPOSE INVITE'
    # Check disabled button
    # Style validation on disabled button is commented out due to APERTA-7684
    # self.validate_primary_big_disabled_button_style(btn)
    # Enable button to check style
    user_input.send_keys(user['email'] + Keys.ENTER)
    user_input.send_keys(Keys.ENTER)
    time.sleep(.5)
    self.validate_secondary_big_green_button_style(btn)
    user_input.clear()
    return None
