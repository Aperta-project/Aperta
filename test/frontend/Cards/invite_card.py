#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time
import os
import random

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException
from loremipsum import generate_paragraph

from Base.CustomException import ElementDoesNotExistAssertionError, ElementExistsAssertionError
from Base.PostgreSQL import PgSQL
from Base.Resources import docs, supporting_info_files, figures, pdfs
from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class InviteCard(BaseCard):
  """
  Abstract class for Page Object Model of all types of Invite cards
  """
  def __init__(self, driver):
    super(InviteCard, self).__init__(driver)

    # Locators - Instance members
    self._send_invitation_button = (By.CLASS_NAME, 'invitation-item-action-send')
    self._rescind_button = (By.CSS_SELECTOR, 'span.invite-rescind')
    self._recipient_field = (By.ID, 'invitation-recipient')
    self._compose_invitation_button = (By.CLASS_NAME, 'invitation-email-entry-button')
    self._edit_invite_heading = (By.CLASS_NAME, 'invitation-item-full-name')
    self._edit_add_to_queue_btn = (By.CLASS_NAME, 'invitation-email-entry-button')
    self._edit_invite_text_cancel = (By.CSS_SELECTOR, 'button.cancel')
    self._invitation_items = (By.CLASS_NAME, 'active-invitations')
    self._invitation_item_details = (By.CLASS_NAME, 'invitation-item-details')
    self._invitation_email_editor = (By.CLASS_NAME, 'invitation-edit-body')
    self._invitation_save_button = (By.CLASS_NAME, 'invitation-save-button')
    self._invitation_email_body = (By.CLASS_NAME, 'invitation-show-body')
    self._header = (By.CLASS_NAME, 'invitation-item-header')
    # new action buttons
    self._invite_edit_invite_button = (By.CSS_SELECTOR, 'span.invitation-item-action-edit')
    self._invite_delete_invite_button = (By.CSS_SELECTOR, 'span.invitation-item-action-delete')
    self._invite_send_invite_button = (By.CSS_SELECTOR, 'span.invitation-item-action-send')
    # There can be an arbitrary number of invitees, but once one is accepted, all others are
    #   revoked - we retain information about revoked invitations.
    self._invitee_listing = (By.CSS_SELECTOR, 'div.invitation-item')
    self._closed_invitee_listing = (By.CSS_SELECTOR, 'div.invitation-item--closed')
    self._open_invitee_listing = (By.CSS_SELECTOR, 'div.invitation-item--show')
    self._reason_suggestions = (By.CSS_SELECTOR, 'div.invitation-item-decline-info')
    # the following locators assume they will be searched for by find element within the scope of
    #   the above, enclosing div
    self._invitee_full_name = (By.CSS_SELECTOR, 'div.invitation-item-full-name')
    self._invitee_updated_at = (By.CLASS_NAME, 'invitation-item-state-and-date')
    self._invitee_state = (By.CSS_SELECTOR, 'div.invitation-item-status')
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
    # self._get(self._compose_invitation_button).click()
    self._wait_for_element(self._get(self._edit_add_to_queue_btn))
    self._get(self._edit_add_to_queue_btn).click()
    self._wait_for_element(self._get(self._invite_send_invite_button))
    self._get(self._invite_send_invite_button).click()
    # The problem with this next item is that it requires the button to be clickable
    # when after send, the whole invite element is in a readonly state.
    try:
      self.check_for_flash_error()
    except NoSuchElementException:
      logging.error('Error fired on send invite.')
    self.click_close_button()
    time.sleep(1)

  def validate_invite(self, invitee, mmt, title, creator, short_doi):
    """
    Invites the invitee that is passed as parameter, verifying the composed email.
      Makes function and style validations.
    :param invitee: user to invite specified as email, or, if in system, name,
        or username
    :param mmt: the paper type of the paper to validate in invitation
    :param title: title of the manuscript - for validation of invite content. Assumed to be unicode
    :param creator: user object of the creator of the manuscript
    :param short_doi: paper short_doi of the manuscript
    :return void function
    """
    self._wait_for_element(self._get(self._recipient_field))
    self._get(self._recipient_field).send_keys(invitee['email'] + Keys.ENTER)
    self._get(self._compose_invitation_button).click()
    time.sleep(2)
    invitations = self._gets(self._closed_invitee_listing)
    for invite in invitations:
      invite_state = invite.find_element(*self._invitee_state)
      if 'Rescinded' in invite_state.text:
        logging.info('Found rescinded invite, skipping...')
        continue
      else:
        closed_invite_listing = self._get(self._closed_invitee_listing)
        # The following 3 lines need to differentiate the specific invite we are trying to validate
        self._actions.move_to_element(closed_invite_listing).perform()
        invite.click()
        self._get(self._invite_edit_invite_button).click()
        invite_headings = self._gets(self._edit_invite_heading)
        # Since the invitee is potentially off system, we can only validate email
        invite_headings_text = [x.text for x in invite_headings]
        assert any(invitee['email'] in s for s in invite_headings_text), \
            '{0} not found in {1}'.format(invitee['email'], invite_headings_text)
        tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
            self.get_rich_text_editor_instance('invitation-edit-body')
        logging.info('Editor instance is: {0}'.format(tinymce_editor_instance_id))
        invite_text = self.tmce_get_rich_text(tinymce_editor_instance_iframe)
        invite_text = invite_text.replace('&nbsp', ' ')
        assert mmt in invite_text, 'MMT: {0} is not found in\n {1}'.format(mmt, invite_text)
        # Always remember that our ember text always normalizes whitespaces down to one
        #  Painful lesson
        title = self.normalize_spaces(title)
        title = self.strip_tinymce_ptags(title)
        assert title in invite_text, title + '\nNot found in \n' + invite_text
        assert 'PLOS Wombat' in invite_text, invite_text
        assert '***************** CONFIDENTIAL *****************' in invite_text, invite_text
        creator_fn, creator_ln = creator['name'].split(' ')[0], creator['name'].split(' ')[1]
        main_author = u'{0}, {1}'.format(creator_ln, creator_fn)
        assert main_author in invite_text, (main_author, invite_text)
        abstract = PgSQL().query('SELECT abstract '
                                 'FROM papers WHERE short_doi=%s;', (short_doi,))[0][0]
        if abstract is not None:
          abstract = self.strip_tinymce_ptags(abstract)
          # Eff BeautifulSoup - actually, we need to preserve some tags and some entitites so
          #   rolling my own here - this will bite me in the keyster at some point I am certain
          abstract = abstract.replace('&amp;', '&')\
                             .replace('&gt;', '>')\
                             .replace('&lt;', '<')\
                             .replace('<span>', '')\
                             .replace('</span>', '')\
                             .replace('span>', '')\
                             .replace('<p>', '')\
                             .replace('</p>', '')\
                             .replace('<sub>', '')\
                             .replace('</sub>', '')\
                             .replace('<sup>', '')\
                             .replace('</sup>', '') \
                             .replace('/p>', '')  # Not sure how this got in there but it did
                                                  #  get through once...

          # Always remember that our ember text always normalizes whitespaces down to one
          #  Painful lesson
          abstract = self.normalize_spaces(abstract)

          invite_text = self.normalize_spaces(invite_text)
          assert abstract in invite_text, u'{0} \n\nnot in\n\n {1}'.format(abstract, invite_text)
        else:
          # APERTA-10626
          # assert 'Abstract is not available' in invite_text, invite_text
          logging.info('No abstract extracted for paper.')

    # Attach a file
    sample_files = docs + pdfs + figures + supporting_info_files
    file_1, file_2 = random.sample(sample_files, 2)
    logging.info('File 1 is {0}\nFile 2 is {1}'.format(file_1, file_2))
    fn = os.path.join(os.getcwd(), file_1)
    logging.info('Attaching file: {0}'.format(fn))
    self.attach_file(fn)

    # see note about sleep below, same applies here with additional complication of possible exceptions
    # this code block essentially says that ElementDoesNotExistAssertionError is the same as len(self._gets(self._replace_attachment)) < 1

    self._wait_on_lambda(lambda: len(self._gets(self._replace_attachment)) >= 1)

    # look for file name and replace attachment link
    self._wait_for_element(self._get(self._replace_attachment))
    attachments = self.get_attached_file_names()
    fn = fn.split('/')[-1].replace(' ', '+')
    assert fn in attachments, '{0} not in {1}'.format(fn, attachments)

    # Attach a second file
    fn = os.path.join(os.getcwd(), file_2)
    logging.info('Attaching file: {0}'.format(fn))
    self.attach_file(fn)

    # Used to have a long sleep here that would still occasionally fail resulting in a index error below
    self._wait_on_lambda(lambda: len(self._gets(self._replace_attachment)) >= 2, max_wait=60)

    # look for file name and replace attachment link
    self._wait_for_element(self._gets(self._replace_attachment)[1])
    attachments = self.get_attached_file_names()
    fn = fn.split('/')[-1].replace(' ', '+')
    assert fn in attachments, '{0} not in {1}'.format(fn, attachments)

    # Save invite with attachments
    self._get(self._invitation_save_button).click()

    # This next action closes the invite again
    self._get(self._invitee_full_name).click()
    invitees = self._gets(self._invitee_listing)
    assert any(invitee['name'] in s for s in [x.text for x in invitees]), \
        '{0} not found in {1}'.format(invitee['name'], [x.text for x in invitees])
    self._get(self._invitee_state)
    # Send the invitation
    self._get(self._send_invitation_button).click()

    # This wait is needed for the invite text to appear
    time.sleep(2)
    invitees = self._gets(self._invitee_listing)
    assert any('Invited' in s for s in [x.text for x in invitees]), \
        'Invited not found in {0}'.format([x.text for x in invitees])

    for item in self._gets(self._invitee_listing):
      if invitee['email'] in item.text and 'Rescinded' not in item.text:
        # So the issue is that the thing you need to click on is the thing with the link/js function
        #   upon it. So in this case, it can't be the full name, it must be the listing itself.
        item.click()
        self._get(self._rescind_button)
        break

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
    # Skip over rescinded invites
    invitations = self._gets(self._closed_invitee_listing)
    for invite in invitations:
      invite_state = invite.find_element(*self._invitee_state)
      if 'Rescinded' in invite_state.text:
        logging.info('Found rescinded invite, skipping...')
      else:
        pagefullname = False
        count = 0
        while not pagefullname:
          pagefullname = invite.find_element(*self._invitee_full_name)
          count += 1
          time.sleep(.5)
          if count > 60:
            raise(Exception, 'Full name not present, aborting')
        assert invitee['name'] in pagefullname.text
        status = invite.find_element(*self._invitee_state)
        assert response in ['Accept', 'Decline'], response
        if response == 'Accept':
          # Review due vs. Review pending is a feature flag.  Eventually we can remove Review pending
          assert 'Review due' in status.text \
                 or 'Review pending' in status.text \
                 or 'Accepted' in status.text, status.text
        elif response == 'Decline':
          # Need to extend box to display text
          assert 'Decline' in status.text, status.text
          status.click()
          reason_suggestions = self._get(self._reason_suggestions).text
          reason_suggestions = self.normalize_spaces(reason_suggestions)
          assert reason in reason_suggestions, u'{0} not in {1}'.format(reason, reason_suggestions)
          assert suggestions in reason_suggestions, u'{0} not in {1}'.format(reason,
                                                                             reason_suggestions)

  def validate_card_elements_styles(self, user, card_type, short_doi):
    """
    Style check for the card
    :param user: User (AE or Reviewer) to send the invitation
    :param card_type: One of either 'ae' or 'reviewer' to indicate the card type
    :param short_doi: Used to pass through to validate_common_elements_styles
    :return None
    """
    assert card_type in ('ae', 'reviewer'), 'Invalid card type passed to function ' \
                                                 'validate_card_elements_styles(): ' \
                                                 '{0}'.format(card_type)
    self.validate_common_elements_styles(short_doi)
    user_input = self._get(self._recipient_field)
    # APERTA-9291 - color fail
    # self.validate_input_field_placeholder_style(user_input)
    card_title = self._get(self._card_heading)
    if card_type == 'reviewer':
      assert card_title.text == 'Invite Reviewers', card_title.text
      assert user_input.get_attribute('placeholder') == 'Invite reviewer by name or email' ,\
          user_input.get_attribute('placeholder')
    elif card_type == 'ae':
      assert card_title.text == 'Invite Academic Editor', card_title.text
      assert user_input.get_attribute('placeholder') == 'Invite editor by name or email',\
          user_input.get_attribute('placeholder')
    self.validate_overlay_card_title_style(card_title)
    # Button
    btn = self._get(self._compose_invitation_button)
    assert btn.text == 'ADD TO QUEUE', '{0} instead of ADD TO QUEUE'.format(btn.text)
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
      revoke = self._get(self._rescind_button)
      logging.info('Checking for match between invitee to be revoked: {0} and '
                   'invitation listing {1}'.format(invitee['name'], pagefullname.text))
      if invitee['name'] in pagefullname.text:
        logging.info('Removing role {0} for {1}'.format(role, invitee['name']))
        revoke.click()
        # Close the open revoked invite so the status will be present
        logging.info('Closing Revoked invite...')
        pagefullname.click()
    self._validate_invitation_revocation(invitee, role)

  def validate_invitation(self, invitee, role):
    """
    A method to validate the invitation for a role for a user
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
    An internal method to validate the revocation of an invite for a role for a user
    :param invitee: person for whom the invite should have been revoked
    :param role: role whose invite should have been revoked for the assignee
    :return: void function
    """
    # It is very important to CLOSE any open invites or state information will not be present where
    #   we are looking for it.
    oes = False
    self.set_timeout(5)
    try:
      opened_invitations = self._gets(self._open_invitee_listing)
      oes = True
    except ElementDoesNotExistAssertionError:
      logging.info('There are no expanded invitation listings')
    self.restore_timeout()
    if oes:
      for opened_invite in opened_invitations:
        pagefullname = opened_invite.find_element(*self._invitee_full_name)
        pagefullname.click()

    invited = self._gets(self._invitee_listing)
    for invitation in invited:
      pagefullname = invitation.find_element(*self._invitee_full_name)
      logging.info('Checking invitee ({0}) for match among remaining '
                   'invitees'.format(invitee['name']))
      if invitee['name'] in pagefullname.text:
        state = invitation.find_element(*self._invitee_state).text
        logging.info(state)
        if 'Rescinded' not in state:
          raise ElementExistsAssertionError('Invitation for {0} and {1} - should have been '
                                            'Rescinded'.format(invitee['name'], role))

  def add_invitee_to_queue(self, invitee):
    """
    Adds an invitee to the queue
    :param invitee: person who will be added to the queue of invitees
    :return: void function
    """
    self._wait_for_element(self._get(self._recipient_field))
    self._get(self._recipient_field).send_keys(invitee['email'] + Keys.ENTER)
    self._get(self._compose_invitation_button).click()
    # In order to wait long enough for another invitee to be added, should this method be called multiple times,
    # find the "ADD TO QUEUE" button element:
    self._driver.find_element_by_class_name('button--disabled')

  def validate_email_template_edits(self):
    """
    Validates ability to expand invitation items within the queue and edit the email template. Edits
    to email templates should persist, to enable saving the template and sending at a later date.
    :return: void function
    """
    invitation_items = self._get(self._invitation_items).find_elements_by_class_name('invitation-item')
    first_invitation_item = random.choice(invitation_items)
    logging.info('First invitation item: {0}'.format(first_invitation_item))
    if len(invitation_items) > 1:
      first_invitation_item.click()
      assert 'invitation-item--show' in first_invitation_item.get_attribute('class'), \
        first_invitation_item.get_attribute('class')
      # Verify that the invitation collapses when clicking the invitation item header
      first_invitation_item.find_element_by_class_name('invitation-item-header').click()
      assert 'invitation-item--closed' in first_invitation_item.get_attribute('class'), \
        first_invitation_item.get_attribute('class')
      # Only one item at most should be expanded. Select a different invitation item, and check
      #   that only it is expanded
      first_invitation_item.click()
      invitation_items.remove(first_invitation_item)
      second_invitation_item = random.choice(invitation_items)
      second_invitation_item.click()
      invitation_items = self._get(self._invitation_items).find_elements_by_class_name('invitation-item')
      expanded_items = filter(lambda item: 'invitation-item--show' in item.get_attribute('class'),
                              invitation_items)
      expanded_items = list(expanded_items)
      assert len(expanded_items) == 1, 'There is more than one expanded item: {0}'.format(expanded_items)

    # Verify editable state when an invitation item is expanded
    first_invitation_item.click()
    self._get(self._invitation_item_details)
    self._get(self._invite_edit_invite_button).click()
    # When in edit mode, ability to collapse the invite item is disabled
    first_invitation_item.find_element_by_class_name('invitation-item-header').click()
    assert 'invitation-item--edit' in first_invitation_item.get_attribute('class'), \
      first_invitation_item.get_attribute('class')
    # Verify that edits to email template persist
    tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
        self.get_rich_text_editor_instance('invitation-edit-body')
    logging.info('Editor instance is: {0}'.format(tinymce_editor_instance_id))
    paragraph = generate_paragraph()[2]
    self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=paragraph)

    time.sleep(1)
    self._get(self._invitation_save_button).click()
    # Collapse and re-expand this invitation item, and check that the paragraph is present
    first_invitation_item.find_element_by_class_name('invitation-item-header').click()
    first_invitation_item.click()
    email_body = self._get(self._invitation_email_body)
    assert paragraph in email_body.text, '{0}\nis not in\n{1}.'.format(paragraph, email_body.text)
