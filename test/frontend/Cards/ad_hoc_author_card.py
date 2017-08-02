#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Page Object definition for the Ad-hoc for authors card
"""

from frontend.Cards.ad_hoc_card import AHCard

__author__ = 'sbassi@plos.org'


class AHAuthorCard(AHCard):
  """
  Page Object Model for Ad Hoc for Authors Card
  """
  def __init__(self, driver):
    super(AHAuthorCard, self).__init__(driver)

    # Locators - Instance members
    # self._invite_editor_text = (By.CLASS_NAME, 'invite-editor-text')
