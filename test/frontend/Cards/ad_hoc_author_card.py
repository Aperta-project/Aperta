#!/usr/bin/env python2
# -*- coding: utf-8 -*-
from frontend.Cards.ad_hoc_card import AHCard

__author__ = 'sbassi@plos.org'

class AHAuthorCard(AHCard):
  """
  Page Object Model for Ad Hoc for Authors Card
  """
  def __init__(self, driver):
    super(AHAuthorCard, self).__init__(driver)

    # Locators - Instance members
    #self._invite_editor_text = (By.CLASS_NAME, 'invite-editor-text')
