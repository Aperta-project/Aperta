#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the base Admin Page, Cards Tab. Validates elements and their styles,
and functions.
"""
import logging
import random
import time

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.PostgreSQL import PgSQL
from styles import APERTA_BLUE
from base_admin import BaseAdminPage

__author__ = 'jgray@plos.org'


class AdminCardsPage(BaseAdminPage):
  """
  Model the common base Admin page, Cards Tab elements and their functions
  """
  def __init__(self, driver):
    super(AdminCardsPage, self).__init__(driver)

    # Locators - Instance members
    self._admin_cards_pane_title = (By.CSS_SELECTOR, 'div.admin-page-content > div > h2')
    self._admin_cards_add_new_card_btn = (By.CLASS_NAME, 'button-primary')
    # self._admin_cards_catalogue = (By.CSS_SELECTOR, 'div.admin-page-catalogue')
    self._admin_cards_catalogue = (By.CLASS_NAME, 'admin-page-catalogue')
    self._admin_cards_card_thumbnail = (By.CLASS_NAME, 'admin-catalogue-item')
    self._admin_cards_thumbnail_item_name = (By.CLASS_NAME, 'admin-card-thumbnail-name')
    self._admin_cards_thumbnail_item_jrnl = (By.CLASS_NAME, 'admin-card-thumbnail-journal')
    # Add New Card Overlay (anco)
    self._admin_cards_anco = (By.CSS_SELECTOR, 'div.overlay-container')
    self._admin_cards_anco_closer = (By.CLASS_NAME, 'overlay-close')
    self._admin_cards_anco_title = (By.CSS_SELECTOR, 'div.overlay-body > div > h1')
    self._admin_cards_anco_name_field_label = (By.CSS_SELECTOR,
                                               'div.admin-new-card-overlay-form label')
    self._admin_cards_anco_name_field = (By.CSS_SELECTOR,
                                         'div.admin-new-card-overlay-form > div > div > input')
    self._admin_cards_anco_name_field_note = (By.CSS_SELECTOR,
                                              'div.admin-new-card-overlay-form > div + p')
    self._admin_cards_anco_cancel_link = (By.CSS_SELECTOR, 'button.admin-new-card-overlay-cancel')
    self._admin_cards_anco_create_btn = (By.CSS_SELECTOR, 'button.admin-new-card-overlay-save')
    # Edit Card Overlay
    # TODO: Outside the scope of this ticket

  # POM Actions
  def page_ready(self):
    """"Ensure the page is ready to test"""
    self._wait_for_element(self._get(self._admin_cards_catalogue))

  def validate_cards_pane(self, selected_jrnl):
    """
    Assert the existence and function of the elements of the Workflows pane.
    Validate Add new card, edit/delete existing card, validate presentation.
    :param selected_jrnl: The name of the selected journal for which to validate the workflow pane
    :return: void function
    """
    # Time to fully populate Cards for selected journal
    time.sleep(1)
    all_journals = False
    dbcards = []
    dbids = []
    cards = []
    cards_pane_title = self._get(self._admin_cards_pane_title)
    self.validate_application_h2_style(cards_pane_title)
    assert 'Card Catalogue' in cards_pane_title.text, cards_pane_title.text
    # Ostorozhna: The All My Journals selection is a special case. There is no add card button
    # and there will be no defined jid
    logging.info('Validating card display for {0}.'.format(selected_jrnl))
    # only validate add new mmt button if not all my journals
    if selected_jrnl not in ('All My Journals', 'All'):
      add_card_btn = self._get(self._admin_cards_add_new_card_btn)
      assert 'ADD NEW CARD' in add_card_btn.text, add_card_btn.text
    self.set_timeout(3)
    # Now a guard to ensure we are in a reasonable data state
    try:
      cards = self._gets(self._admin_cards_card_thumbnail)
    # I know this looks weird, but I want an explicit error string for this failure if it occurs
    except ElementDoesNotExistAssertionError:
      # For the forseeable future (~6 month timeline), it will happen that there will be journals
      #   without defined cards.
      # raise ElementDoesNotExistAssertionError('No extant Cards found for Journal. '
      #                                         'This should never happen.')
      logging.info('No Cards found for journal: {0}'.format(selected_jrnl))
    self.restore_timeout()
    try:
      # The canonical form of this full url is, for example:
      #   http://rc.aperta.tech/admin/cc/journals/workflows?journalID=3
      jid = self._driver.current_url.split('=')[1]
    except IndexError:
      logging.info("We are on the All journals selection, have to roll up all cards")
      all_journals = True
    if not all_journals:
      db_cards = PgSQL().query('SELECT name, id '
                               'FROM cards '
                               'WHERE journal_id = %s;', (jid,))
    else:
      db_cards = PgSQL().query('SELECT name, id '
                               'FROM cards;')
    logging.info(db_cards)
    for dbcard in db_cards:
      logging.debug('Appending {0} to dbcards'.format(dbcard[0]))
      dbcards.append(dbcard[0])
      dbids.append(dbcard[1])
    logging.info(dbids)
    if dbcards:
      for card in cards:
        name = card.find_element(*self._admin_cards_thumbnail_item_name)
        logging.info('Examining Card: {0}'.format(name.text))
        assert name.text in dbcards, name.text
        journal = card.find_element(*self._admin_cards_thumbnail_item_jrnl)
        logging.info('Validating Card for journal: {0}'.format(journal.text))
        if all_journals:
          jid = PgSQL().query('SELECT id '
                              'FROM journals '
                              'WHERE LOWER(name) = %s;', (journal.text.lower(),))[0][0]
          logging.info(jid)
          jid = int(jid)
          logging.info('JID is {0}'.format(jid))
        card_id = PgSQL().query('SELECT id '
                                'FROM cards '
                                'WHERE journal_id = %s '
                                'AND name = %s;', (jid, name.text))
        assert card_id, 'No card named "{0}" in journal: {1}'.format(name.text, journal.text)
        assert card.value_of_css_property('background-color') == APERTA_BLUE, \
            card.value_of_css_property('background-color')
        # Validate Color shift on hover
        self._actions.move_to_element_with_offset(card, 5, 5).perform()
        # The hover color of the mmt thumbnails is not present in the approved palette in the
        #   style guide. Currently only a question in APERTA-8989.
        # assert mmt.value_of_css_property('background-color') == APERTA_BLUE_DARK, \
        #   mmt.value_of_css_property('background-color')
    if not all_journals:
      add_card_btn.click()
      # The add new card overlay (modal) uses an animation to draw. The following sleep in a
      #  temporary shorthand because this overlay test is beyond the scope of APERTA-8989. When
      #  we get the ticket that covers card creation this should be removed.
      time.sleep(2)
      self._validate_add_card_definition_overlay(selected_jrnl)

  def _validate_add_card_definition_overlay(self, journal):
    """
    Validates the elements and styles of the Add New Card overlay. Stops short of committing new
      cards as the delete card method is not implemented in the underlying product.
    :param journal: the journal context within which the Add New Card button was called
    :return: void function
    """
    self._wait_for_element(self._get(self._admin_cards_anco))
    closer = self._get(self._admin_cards_anco_closer)
    title = self._get(self._admin_cards_anco_title)
    assert title.text == 'Add new card to {0}'.format(journal), title.text
    self.validate_application_section_heading_style(title, admin=True)
    name_field_label = self._get(self._admin_cards_anco_name_field_label)
    assert name_field_label.text == 'Name your new card:', name_field_label.text
    name_field = self._get(self._admin_cards_anco_name_field)
    name_field_note = self._get(self._admin_cards_anco_name_field_note)
    assert name_field_note.text == 'Note: this name will not appear to external audiences. ' \
                                   'It can be edited at any time.', name_field_note.text
    cancel_link = self._get(self._admin_cards_anco_cancel_link)
    assert cancel_link.text == 'cancel', cancel_link.text
    save_link = self._get(self._admin_cards_anco_create_btn)
    assert save_link.text == 'CREATE NEW CARD', save_link.text
    choices = [closer, cancel_link]
    choice = random.choice(choices)
    choice.click()
    time.sleep(1)

