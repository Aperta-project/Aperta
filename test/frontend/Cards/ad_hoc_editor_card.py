#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object definition for the Ad-hoc for editors card
"""
from frontend.Cards.ad_hoc_card import AHCard

__author__ = 'sbassi@plos.org'


class AHEditorCard(AHCard):
  """
  Page Object Model for Invite AE Card
  """
  def __init__(self, driver):
    super(AHEditorCard, self).__init__(driver)

    # Locators - Instance members
    # self._invite_editor_text = (By.CLASS_NAME, 'invite-editor-text')
