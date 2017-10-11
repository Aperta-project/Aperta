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
    #self._invite_editor_text = (By.CLASS_NAME, 'invite-editor-text')
