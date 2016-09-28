#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import re
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from Base.PostgreSQL import PgSQL
from frontend.Cards.invite_card import InviteCard

__author__ = 'sbassi@plos.org'

class InviteAECard(InviteCard):
  """
  Page Object Model for Invite AE Card
  """
  def __init__(self, driver):
    super(InviteAECard, self).__init__(driver)

    # Locators - Instance members
    self._invite_editor_text = (By.CLASS_NAME, 'invite-editor-text')

    # the following locators assume they will be searched for by find element within the scope of
    #   the above, enclosing div
    self._reason_suggestions = (By.CLASS_NAME, 'invitation-item-decline-info')

  def _check_style(self, user, paper_id):
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
