#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import re
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.PostgreSQL import PgSQL
from frontend.Cards.basecard import BaseCard


__author__ = 'sbassi@plos.org'

class ReviewerReportCard(BaseCard):
  """
  Page Object Model for Reviewer Report Card
  """
  def __init__(self, driver):
    super(ReviewerReportCard, self).__init__(driver)
    # Locators - Instance members


    self._edit_invite_heading = (By.CSS_SELECTOR, 'h3.invite-to')
    self._edit_invite_textarea = (By.CSS_SELECTOR, 'div.taller-textarea')
    self._edit_invite_text_cancel = (By.CSS_SELECTOR, 'button.cancel')
    self._edit_invite_text_send_invite_button = (By.CSS_SELECTOR, 'button.invite-reviewer-button')

    self._invitees_table = (By.CLASS_NAME, 'invitees')


  # POM Actions
  def validate_card_elements_styles(self, paper_id):
    """
    This method validates the styles of the card elements including the common card elements
    :return void function
    """
    self.validate_common_elements_styles(paper_id)

  def validate_reviewer_report(self):
    """
    Invites the reviewer that is passed as parameter, verifying the composed email. Makes
      function and style validations.
    :param reviewer: user to invite as reviewer specified as email, or, if in system, name,
        or username
    :param title: title of the manuscript - for validation of invite content. Assumed to be unicode
    :param creator: user object of the creator of the manuscript
    :param manu_id: paper id of the manuscript
    :return void function
    """
    time.sleep(.5)
    self._get(self._recipient_field).send_keys(reviewer['email'] + Keys.ENTER)
    self._get(self._compose_invitation_button).click()
    time.sleep(2)
    invite_heading = self._get(self._edit_invite_heading).text
    # Since the reviewer is potentially off system, we can only validate email
    assert reviewer['email'] in invite_heading, invite_heading
    invite_text = self._get(self._edit_invite_textarea).text
    # Always remember that our ember text always normalizes whitespaces down to one
    #  Painful lesson
    title = re.sub(r'[ \t\f\v]+', ' ', title)
    # and need to scrub latin-1 non-breaking spaces
    title = re.sub(u'\xa0', u' ', title)
    assert title in invite_text, \
        title + '\nNot found in \n' +invite_text
    assert 'PLOS Wombat' in invite_text, invite_text
    assert '***************** CONFIDENTIAL *****************' in invite_text, invite_text
    creator_fn, creator_ln = creator['name'].split(' ')[0], creator['name'].split(' ')[1]
    assert '{0}, {1}'.format(creator_ln, creator_fn) in invite_text, invite_text
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
    self._get(self._edit_invite_text_send_invite_button).click()
    time.sleep(1)
    invitee = self._get(self._invitee_listing)
    invitee.find_element(*self._invitee_avatar)
    invitee.find_element(*self._invitee_full_name)
    invitee.find_element(*self._invitee_updated_at)
    status = invitee.find_element(*self._invitee_state)
    invitee.find_element(*self._invitee_revoke)
    self.validate_invitation(reviewer, 'Reviewer')
    assert 'Invited' in status.text, status.text
