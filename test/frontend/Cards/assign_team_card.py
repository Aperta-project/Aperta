#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import re
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from frontend.Cards.basecard import BaseCard


__author__ = 'jgray@plos.org'


class AssignTeamCard(BaseCard):
  """
  Page Object Model for the Assign Team Card
  """
  def __init__(self, driver):
    super(AssignTeamCard, self).__init__(driver)

    # Locators - Instance members
    self.assign_team_role_label = (By.CSS_SELECTOR,
                                   'span.assign_team_select2_container_first > label')
    self.assign_team_role_selector = (By.CSS_SELECTOR, 'div.assignment-role-input')
    self.assign_team_role_search_field = (By.CSS_SELECTOR, 'div.select2-drop-active input')
    self.assign_team_user_label = (
        By.CSS_SELECTOR,
        'span.assign_team_select2_container + span.assign_team_select2_container > label')
    self.assign_team_user_selector = (By.CSS_SELECTOR, 'div.assignment-user-input')
    self.assign_team_user_search_field = (
        By.XPATH,
        '//div[@class="select2-drop select2-display-none select2-with-searchbox select2-drop-active"][2]/div/input')
    self.assign_team_assign_button = (By.CSS_SELECTOR,
                                      'span.assign_team_select2_container + button')

    self._assignees_table = (By.CLASS_NAME, 'assignments')
    # There can be an arbitrary number of invitees, but once one is accepted, all others are
    #   revoked - we retain information about revoked invitations.
    self._assignee_listing = (By.CSS_SELECTOR, 'tr.assignment')
    # the following locators assume they will be searched for by find element within the scope of
    #   the above, enclosing div
    self._assignee_avatar = (By.CSS_SELECTOR, 'img.assignee-thumbnail')
    self._assignee_full_name = (By.CSS_SELECTOR, 'span.assignee-full-name')
    self._assignee_role_clause = By.CSS_SELECTOR, 'tr.assignment > td + td'
    self._assignee_updated_at = (By.CSS_SELECTOR, 'span.assignment-updated-at')
    self._assignee_state = (By.CSS_SELECTOR, 'span.assignment-state')
    self._assignee_revoke = (By.CSS_SELECTOR, 'span.assignment-remove')

  # POM Actions
  def validate_card_elements_styles(self, paper_id):
    """
    This method validates the styles of the card elements including the common card elements
    :param paper_id: ID of paper for passing through to validate_common_elements_styles()
    :return void function
    """
    self.validate_common_elements_styles(paper_id)
    title = self._get(self._card_heading)
    assert 'Assign Team' in title.text, title.text
    # self.validate_card_header(title)

  def assign_role(self, person, role):
    """
    Assigns the academic editor that is passed as parameter.
    :param person: user to assign as role specified as email, or, if in system, name,
      or username
    :param role: role to assign user to - valid choices are: Academic Editor, Cover Editor,
      Handling Editor or Reviewer.
    :return void function
    """
    logging.info('Assigning {0}'.format(role))
    self._get(self.assign_team_role_selector).click()
    role_input = self._get(self.assign_team_role_search_field)
    role_input.send_keys(role + Keys.ENTER)
    self._get(self.assign_team_user_selector).click()
    user_input = self._get(self.assign_team_user_search_field)
    user_input.send_keys(person['email'])
    # Need time for the lookup to complete
    time.sleep(4)
    # once more with feeling to commit the selection
    user_input.send_keys(Keys.ENTER)
    time.sleep(1)
    self._get(self.assign_team_assign_button).click()
    time.sleep(1)
    self._validate_assignment(person, role)
    time.sleep(1)

  def _validate_assignment(self, assignee, role):
    """
    internal method to validate via the UI that a user has received an assignment
    :param assignee: the user dictionary to validate against
    :param role: the role for which the user should have been assigned
    :return: void function
    """
    assigned = self._gets(self._assignee_listing)
    for assignment in assigned:
      assignment.find_element(*self._assignee_avatar)
      pagefullname = assignment.find_element(*self._assignee_full_name)
      role_clause = assignment.find_element(*self._assignee_role_clause)
      assignment.find_element(*self._assignee_updated_at)
      status = assignment.find_element(*self._assignee_state)
      try:
        assert assignee['name'] in pagefullname.text, pagefullname.text
        assert role in role_clause.text, role_clause.text
        assert 'Assigned' in status.text, status.text
      except AssertionError:
        logging.info('No Match found in {0}'.format(assignment.text))
        continue

  def revoke_assignment(self, assignee, role):
    """
    A method to revoke an assignment (role) for a user (assignee)
    :param assignee: The user with the role to revoke
    :param role: The role to revoke
    :return: void function
    """
    assigned = self._gets(self._assignee_listing)
    for assignment in assigned:
      pagefullname = assignment.find_element(*self._assignee_full_name)
      role_clause = assignment.find_element(*self._assignee_role_clause)
      revoke = assignment.find_element(*self._assignee_revoke)
      if role in role_clause.text:
        logging.info('Found role, checking assignee ({0}) for match'.format(assignee['name']))
        if assignee['name'] in pagefullname.text:
          logging.info('Removing role {0} for {1}'.format(role, assignee['name']))
          revoke.click()
    self._validate_assignment_revocation(assignee, role)

  def _validate_assignment_revocation(self, assignee, role):
    """
    an internal method to validate the revocation of a role for a user
    :param assignee: person for whom the role should have been revoked
    :param role: role that should have been revoked for the assignee
    :return: void function
    """
    assigned = self._gets(self._assignee_listing)
    for assignment in assigned:
      pagefullname = assignment.find_element(*self._assignee_full_name)
      role_clause = assignment.find_element(*self._assignee_role_clause)
      revoke = assignment.find_element(*self._assignee_revoke)
      if role in role_clause.text:
        logging.info('Found role, checking assignee ({0}) for match'.format(assignee['name']))
        if assignee['name'] in pagefullname.text:
          raise('Revoked assignment found for {0} and {1}'.format(assignee['name'], role))
