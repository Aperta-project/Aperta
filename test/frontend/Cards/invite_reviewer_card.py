#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from frontend.Cards.invite_card import InviteCard

__author__ = 'jgray@plos.org'


class InviteReviewersCard(InviteCard):
  """
  Page Object Model for Invite Reviewer Card
  """
  def __init__(self, driver):
    super(InviteReviewersCard, self).__init__(driver)

    # Locators - Instance members
  # POM Actions
