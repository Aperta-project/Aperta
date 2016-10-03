#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import re
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.PostgreSQL import PgSQL
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
