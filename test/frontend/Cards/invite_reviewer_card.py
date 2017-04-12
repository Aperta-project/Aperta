#!/usr/bin/env python2
# -*- coding: utf-8 -*-
from selenium.webdriver.common.by import By

from frontend.Cards.invite_card import InviteCard

__author__ = 'jgray@plos.org'


class InviteReviewersCard(InviteCard):
  """
  Page Object Model for Invite Reviewer Card
  """
  def __init__(self, driver):
    super(InviteReviewersCard, self).__init__(driver)

    # Locators - Instance members
    self._invitee_report_state = (By.CSS_SELECTOR, 'div.invitation-item-status span:not(.not-bold)')
  # POM Actions

  def validate_invited_reviewer_report_state(self, invitee, expected_report_state='pending'):
    """
    test_invited_reviewer_report_state: Validates if all the elements for a report state are like expected
    :param invitee: The invited reviewer
    :param expected_report_state: The expected report state (pending or completed)
    :return: void function
    """
    invites = self._gets(self._invitee_listing)
    invite_found = False
    accepted_report_state = ['pending', 'completed']

    assert expected_report_state in accepted_report_state, 'The report state is not valid.'

    for invite in invites:
      name = invite.find_element(*self._invitee_full_name).text
      if invitee['name'] in name:
        invite_found = True

        assert 'invitation-state--accepted' in invite.get_attribute('class'), 'The invite is not accepted'

        report_state = invite.find_element(*self._invitee_report_state)

        if expected_report_state == 'pending':
          assert report_state.text == 'Pending', 'The report state: {0} is not the expected: Pending'.format(report_state.text)
          invite.find_element_by_css_selector('div.invitation-item-status span.not-bold')
        elif expected_report_state == 'completed':
          assert 'Completed' in report_state.text, 'The report state: {0} has no completion'.format(report_state.text)
          invite.find_element_by_css_selector('div.invitation-item-status .invitation-item-review-completed-icon')

    assert invite_found, 'No invite was found to: {0}'.format(invitee['name'])