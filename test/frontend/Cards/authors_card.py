#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Page object definition for the authors card
"""
import time
import random
import logging
import datetime

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from frontend.Cards.basecard import BaseCard
from Base.Resources import author
from Base.PostgreSQL import PgSQL

__author__ = 'sbassi@plos.org'


class AuthorsCard(BaseCard):
  """
  Page Object Model for Authors Card
  """
  def __init__(self, driver):
    super(AuthorsCard, self).__init__(driver)

    # Locators - Instance members
    self._click_task_completed = (By.CSS_SELECTOR, '#task_completed')
    self._close_button_bottom = (By.CSS_SELECTOR, 'footer > div > a.button-secondary')
    self._authors_title = (By.TAG_NAME, 'h1')
    self._authors_text = (By.CSS_SELECTOR, 'div.overlay-main-work > p')
    self._add_new_author_btn = (By.CLASS_NAME, 'button-primary')
    self._first_lbl = (By.XPATH, ".//div[contains(@class, 'author-name')]/span")
    self._first_input = (By.XPATH, ".//div[contains(@class, 'author-name')]/input")
    self._middle_lbl = (By.XPATH, ".//div[contains(@class, 'author-middle')]/span")
    self._middle_input = (By.XPATH, ".//div[contains(@class, 'author-middle')]/input")
    self._last_lbl = (By.XPATH, ".//div[contains(@class, 'author-top')]/div[3]/span")
    self._last_input = (By.XPATH, ".//div[contains(@class, 'author-top')]/div[3]/input")
    self._email_lbl = (By.XPATH, ".//div[contains(@class, 'author-half')]/span")
    self._email_input = (By.XPATH, ".//div[contains(@class, 'author-half')]/input")
    self._title_lbl = (By.XPATH, ".//div[contains(@class, 'add-author-form')]/div[2]/div/span")
    self._title_input = (By.XPATH, ".//div[contains(@class, 'add-author-form')]/div[2]/div/input")
    self._department_lbl = (
        By.XPATH, ".//div[contains(@class, 'add-author-form')]/div[2]/div[2]/span")
    self._department_input = (
        By.XPATH, ".//div[contains(@class, 'add-author-form')]/div[2]/div[2]/input")
    self._institution_div = (By.CLASS_NAME, 'did-you-mean-input')
    self._author_lbls = (By.CLASS_NAME, 'author-label')
    self._designed_chkbx = (
        By.XPATH, './/input[@name=\'author--contributions--conceived_and_designed_experiments\']/'
        'following-sibling::span')
    self._author_contrib_lbl = (By.CSS_SELECTOR, 'h4.required')
    self._add_author_cancel_lnk = (By.CSS_SELECTOR, 'span.author-form-buttons a')
    self._add_author_add_btn = (By.CSS_SELECTOR, 'span.author-form-buttons button')
    self._author_items = (By.CSS_SELECTOR, 'div.author-task-item')
    self._delete_author_div = (By.CLASS_NAME, 'authors-overlay-item--delete')
    self._edit_author = (By.CLASS_NAME, 'fa-pencil')
    self._corresponding = (
        By.XPATH, ".//input[@name='author--published_as_corresponding_author']")
    self._add_author_add_btn = (By.CSS_SELECTOR, 'div.author-form-buttons > button')
    self._delete_author_item = (By.CLASS_NAME, 'fa-trash')

    # co-author related locators
    self._coauthor_confirm_lbl = (By.CLASS_NAME, 'confirm-coauthor-label')
    self._coauthor_decline_lbl = (By.CLASS_NAME, 'decline-coauthor-label')
    self._no_response_lbl = (By.CLASS_NAME, 'no-response-coauthor-label')
    self._coauthor_last_mod_info = (By.CLASS_NAME, 'coauthor-status-modified-by')
    self._coauthor_status_info_no_response = (By.CLASS_NAME, 'author-coauthor-info')
    self._coauthor_status_info_confirmed = (By.CLASS_NAME, 'author-confirmed')
    self._coauthor_status_info_declined = (By.CLASS_NAME, 'author-refuted')


  # POM Actions
  def click_task_completed_checkbox(self):
    """Click task completed checkbox"""
    self._get(self._click_task_completed).click()
    return self

  def click_close_button_bottom(self):
    """Click close button on bottom"""
    self._get(self._close_button_bottom).click()
    return self

  def validate_author_card_styles(self):
    """Validate"""
    authors_title = self._get(self._authors_title)
    assert authors_title.text == 'Authors', authors_title.text
    self.validate_application_title_style(authors_title)
    authors_text = self._get(self._authors_text)
    assert authors_text.text == (
        "Our criteria for authorship are based on the 'Uniform Requirements for Manuscripts "
        "Submitted to Biomedical Journals: Authorship and Contributorship'. Individuals whose "
        "contributions fall short of authorship should instead be mentioned in the "
        "Acknowledgments. If the article has been submitted on behalf of a consortium, all "
        "author names and affiliations should be listed at the end of the article."
        )
    self.validate_application_body_text(authors_text)
    add_new_author_btn = self._get(self._add_new_author_btn)
    assert 'ADD A NEW AUTHOR' == add_new_author_btn.text, add_new_author_btn.text
    self.validate_primary_big_green_button_style(add_new_author_btn)

  def validate_author_card_action(self):
    """Validate working of Author Card. Adds and delete a new author"""
    # Add a new author
    self._get(self._add_new_author_btn).click()
    # Check form elements
    first_lbl = self._get(self._first_lbl)
    first_input = self._get(self._first_input)
    middle_lbl = self._get(self._middle_lbl)
    middle_input = self._get(self._middle_input)
    last_lbl = self._get(self._last_lbl)
    last_input = self._get(self._last_input)
    email_lbl = self._get(self._email_lbl)
    email_input = self._get(self._email_input)
    title_lbl = self._get(self._title_lbl)
    title_input = self._get(self._title_input)
    department_lbl = self._get(self._department_lbl)
    department_input = self._get(self._department_input)
    assert first_lbl.text == 'First Name', first_lbl.text
    assert middle_lbl.text == 'MI', middle_lbl.text
    assert last_lbl.text == 'Last Name', last_lbl.text
    assert email_lbl.text == 'Email', email_lbl.text
    assert title_lbl.text == 'Title', title_lbl.text
    assert department_lbl.text == 'Department', department_lbl.text
    assert first_input.get_attribute('placeholder') == 'Jane'
    assert middle_input.get_attribute('placeholder') == 'M'
    assert last_input.get_attribute('placeholder') == 'Goodall'
    assert email_input.get_attribute('placeholder') == 'jane.goodall@science.com'
    assert title_input.get_attribute('placeholder') == "World's Foremost Expert on Chimpanzees"
    assert department_input.get_attribute('placeholder') == 'Primatology'
    institution_div, sec_institution_div = self._gets(self._institution_div)
    institution_input = institution_div.find_element_by_tag_name('input')
    assert institution_input.get_attribute('placeholder') == 'Institution'
    institution_icon = institution_div.find_element_by_css_selector('button i')
    assert set(['fa', 'fa-search']) == set(institution_icon.get_attribute('class').split(' '))
    sec_institution_input = sec_institution_div.find_element_by_tag_name('input')
    assert sec_institution_input.get_attribute('placeholder') == 'Secondary Institution'
    sec_institution_icon = sec_institution_div.find_element_by_css_selector('button i')
    assert set(['fa', 'fa-search']) == set(sec_institution_icon.get_attribute('class').split(' '))
    corresponding_lbl, deceased_lbl, conceived_lbl, perfomed_lbl, data_lbl, \
        materials_lbl, writing_lbl, other_lbl = self._gets(self._author_lbls)
    assert corresponding_lbl.text == ('This person will be listed as the corresponding author'
                                      ' on the published article'), corresponding_lbl.text
    assert deceased_lbl.text == 'This person is deceased'
    assert other_lbl.text == 'Other', other_lbl.text
    assert conceived_lbl.text == 'Conceived and designed the experiments', conceived_lbl.text
    assert perfomed_lbl.text == 'Performed the experiments', perfomed_lbl.text
    assert data_lbl.text == 'Analyzed the data', data_lbl.text
    assert materials_lbl.text == 'Contributed reagents/materials/analysis tools', materials_lbl.text
    assert writing_lbl.text == 'Contributed to the writing of the manuscript', writing_lbl.text

    author_contrib_lbl = self._get(self._author_contrib_lbl)
    assert author_contrib_lbl.text == 'Author Contributions'
    self.validate_application_h4_style(author_contrib_lbl)
    add_author_cancel_lnk = self._get(self._add_author_cancel_lnk)
    add_author_add_btn = self._get(self._add_author_add_btn)
    self.validate_green_on_green_button_style(add_author_add_btn)
    self.validate_default_link_style(add_author_cancel_lnk)
    # fill the data
    first_input.send_keys(author['first'] + Keys.ENTER)
    middle_input.send_keys(author['middle'] + Keys.ENTER)
    last_input.send_keys(author['last'] + Keys.ENTER)
    email_input.send_keys(author['email'] + Keys.ENTER)
    title_input.send_keys(author['title'] + Keys.ENTER)
    department_input.send_keys(author['department'] + Keys.ENTER)
    institution_input.send_keys(author['1_institution'] + Keys.ENTER)
    sec_institution_input.send_keys(author['2_institution'] + Keys.ENTER)
    time.sleep(1)
    add_author_add_btn.click()
    # Check if data is there
    time.sleep(3)
    authors = self._gets(self._author_items)
    all_auth_data = [x.text for x in authors]
    assert [x for x in all_auth_data if author['1_institution'] in x]
    assert [x for x in all_auth_data if author['2_institution'] in x]
    assert [x for x in all_auth_data if author['department'] in x]
    assert [x for x in all_auth_data if author['first'] in x]
    assert [x for x in all_auth_data if author['middle'] in x]
    assert [x for x in all_auth_data if author['title'][-4:] in x]
    assert [x for x in all_auth_data if author['email'] in x]

  def validate_delete_author(self):
    """Check deleteing an author from author card"""
    # Check where is the new data
    authors = self._gets(self._author_items)
    all_auth_data = [x.text for x in authors]
    n = 0
    for auth_data in all_auth_data:
      n += 1
      if author['email'] in auth_data:
        break
    # Get author to delete
    authors = self._gets(self._author_items)
    self._actions.move_to_element(authors[n-1]).perform()
    time.sleep(2)
    # authors = self._gets(self._author_items)
    trash = authors[n-1].find_element_by_css_selector('span.fa-trash')
    trash.click()
    # get buttons
    time.sleep(1)
    delete_div = self._get(self._delete_author_div)
    del_message = delete_div.find_element_by_tag_name('p')
    assert del_message.text == 'This will permanently delete the author. Are you sure?'
    # TODO: Check p style, resume this when styles are set.
    cancel_btn, delete_btn = delete_div.find_elements_by_tag_name('button')
    assert cancel_btn.text == 'CANCEL', cancel_btn.text
    assert delete_btn.text == 'DELETE FOREVER', delete_btn.text
    # TODO: check styles, resume this when styles are set.
    delete_btn.click()
    time.sleep(2)

  def edit_author(self, author_data):
    """Edit the first author in the author card"""
    AuthorsCard(self._driver)
    self._get(self._author_items)
    self._actions.move_to_element(author).perform()
    edit_btn = self._get(self._edit_author)
    edit_btn.click()
    title_input = self._get(self._title_input)
    department_input = self._get(self._department_input)
    institutions = self._gets(self._institution_div)
    if len(institutions) == 2:
      institution_div = institutions[0]
      institution_input = institution_div.find_element_by_tag_name('input')
      institution_input.clear()
      institution_input.send_keys(author_data['institution'] + Keys.ENTER)
    # 'did-you-mean-what-you-meant'
    title_input.clear()
    title_input.send_keys(author_data['title'] + Keys.ENTER)
    department_input.clear()
    department_input.send_keys(author_data['department'] + Keys.ENTER)
    # Author contributions
    corresponding_chck = self._get(self._corresponding)
    if not corresponding_chck.is_selected():
      corresponding_chck.click()
    author_contribution_chck = self._get(self._designed_chkbx)
    if not author_contribution_chck.is_selected():
      author_contribution_chck.click()
    add_author_add_btn = self._get(self._add_author_add_btn)
    add_author_add_btn.click()
    time.sleep(.2)
    self._get(self._close_button).click()

  def update_coauthor_status(self, confirm=True):
    """
    Selects a radio button option to either confirm or decline co-authorship status. This assumes that the
    co-author has not already submitted confirmed/declined via email (we are not able to test that piece yet).
    Note: only admin(site/staff) users should be able to confirm/decline co-authorship status on the authors card.
    :param confirm: The decision taken (accept or decline) for co-author confirmation
    :return: void function
    """
    if confirm:
      self._get(self._coauthor_confirm_lbl).click()
    else:
      self._get(self._coauthor_decline_lbl).click()

  def validate_coauthor_status(self, short_doi):
    """
    Validates the messages that appear on the authors card after confirmation or
    decline of co-author status by an internal user.
    :return: void function
    """
    author_items = self._gets(self._author_items)
    coauthor_item = author_items[1]
    coauthor_item.click()

    # Before updating, the "No Response" radio button will be selected, with its
    # corresponding message:
    expected_no_response_msg = 'When you submit your manuscript, an email will ' \
     'be sent to this coauthor at the address you provide below to confirm authorship'
    no_response_info = self._get(self._coauthor_status_info_no_response)
    assert no_response_info.text == expected_no_response_msg, 'Actual: {0} != Expected: {1}'.format(no_response_info.text, expected_no_response_msg)

    confirm = random.choice([True, False])
    logging.info('Selecting {0} for coauthor confirmation'.format(confirm))
    self.update_coauthor_status(confirm)

    if confirm:
      expected_accept_msg = 'Authorship has been confirmed'
      accept_msg = self._get(self._coauthor_status_info_confirmed)
      assert accept_msg.text == expected_accept_msg, 'Actual: {0} != Expected: {1}'.format(accept_msg.text, expected_accept_msg)
    else:
      expected_decline_msg = 'Authorship has been refuted'
      decline_msg = self._get(self._coauthor_status_info_declined)
      assert decline_msg.text == expected_decline_msg, 'Actual: {0} != Expected: {1}'.format(decline_msg.text, expected_decline_msg)

    self._get(self._add_author_add_btn).click()

    # Now, open the author item for the coauthor and verify that the last modified by info is displayed
    # Getting the trash can icon, so that there is time to wait for the author item
    # div to collapse before opening it again, and avoiding a sleep:
    coauthor_item.find_element(*self._delete_author_item)
    coauthor_item.click()
    last_mod_info = self._get(self._coauthor_last_mod_info)
    if confirm:
      action = 'Confirmed by'
    else:
      action = 'Refuted By'

    coauthor_info_from_db = self.get_coauthor_info_from_db(short_doi)
    coauthor_state_from_db = coauthor_info_from_db[0]
    coauthor_state_modified_at = self.utc_to_local_tz(coauthor_info_from_db[1])
    coauthor_state_modified_by_id = coauthor_info_from_db[2]

    time_confirmed = coauthor_state_modified_at.strftime('%B %-d, %Y %H:%M')
    coauthor_state_modified_by = ' '.join(self.get_user_name_from_id(coauthor_state_modified_by_id))
    expected_last_mod_info = '{0} {1} on {2}'.format(action, coauthor_state_modified_by, time_confirmed)
    assert last_mod_info.text == expected_last_mod_info, 'Actual: {0} != Expected: {1}'.format(last_mod_info.text, expected_last_mod_info)

  def get_coauthor_info_from_db(self, short_doi):
        """
        Retrieves an author's information for coauthor state for a paper from the database.
        :param short_doi: The short for the paper
        :return: co_author_state, co_author_state_modified_at, co_author_state_modified_by_id
        """

        coauthor_info =  PgSQL().query('SELECT papers.id, papers.short_doi,'
                    'author_list_items.author_type, '
                    'authors.id,authors.co_author_state, authors.co_author_state_modified_at, '
                    'authors.co_author_state_modified_by_id FROM papers '
                    'JOIN author_list_items ON author_list_items.paper_id = papers.id '
                    'JOIN authors ON authors.id = author_list_items.author_id WHERE '
                    'papers.short_doi = \'{0}\' order by authors.id DESC;'.format(short_doi))[0]

        coauthor_state = coauthor_info[4]
        coauthor_state_modified_at = coauthor_info[5]
        coauthor_state_modified_by_id = coauthor_info[6]

        return coauthor_state, coauthor_state_modified_at, coauthor_state_modified_by_id

  def get_user_name_from_id(self, user_id):
        """
        Retrieves the user's name from the database, given the user_id
        :params user_id: The user id in the database
        :return: first_name and last_name of user
        """

        names = PgSQL().query('SELECT first_name, last_name FROM users '
                        'WHERE id = {0};'.format(user_id))[0]

        return names
