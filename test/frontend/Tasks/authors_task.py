#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from frontend.Tasks.basetask import BaseTask

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Resources import author

__author__ = 'jgray@plos.org'

class AuthorsTask(BaseTask):
  """
  Page Object Model for Authors Task
  """
  def __init__(self, driver):
    super(AuthorsTask, self).__init__(driver)

    #Locators - Instance members
    self._authors_title = (By.TAG_NAME, 'div.authors-task div.task-disclosure-heading')
    self._authors_text = (By.CSS_SELECTOR, 'div.authors-task div.task-disclosure-body div.task-main-content p')
    self._add_new_author_btn = (By.CSS_SELECTOR,
                                'div.authors-task div.task-disclosure-body div.task-main-content button')
    self._first_lbl = (By.CSS_SELECTOR, 'div.author-name div label')
    self._first_input = (By.CSS_SELECTOR, 'input.author-first')
    self._middle_lbl = (By.CSS_SELECTOR, 'div.author-middle-initial div label')
    self._middle_input = (By.XPATH, ".//div[contains(@class, 'author-middle')]/input")
    self._last_lbl = (By.CSS_SELECTOR, 'div.author-middle-initial + div.author-name div label')
    self._last_input = (By.CSS_SELECTOR, 'input.author-last')
    self._email_lbl = (By.CSS_SELECTOR, 'div.author-middle-initial + div + div div label')
    self._email_input = (By.CSS_SELECTOR, 'input.author-email')
    self._title_lbl = (By.CSS_SELECTOR, 'div.flex-group + div.flex-group div div label')
    self._title_input = (By.CSS_SELECTOR, 'input.author-title')
    self._department_lbl = (By.CSS_SELECTOR, 'div.flex-group + div.flex-group div + div div label')
    self._department_input = (By.CSS_SELECTOR, 'input.author-department')
    self._institution_div = (By.CLASS_NAME, 'did-you-mean-input')
    #self._author_lbls = (By.CLASS_NAME, 'author-label')
    self._author_lbls = (By.CLASS_NAME, 'question-checkbox')
    self._author_other_lbl = (By.CSS_SELECTOR, 'div.author-contributions div.flex-group + div.flex-group '
                                               'div.flex-element label')
    self._designed_chkbx = (By.XPATH,
      ".//input[@name='author--contributions--conceived_and_designed_experiments']/following-sibling::span")
    self._author_contrib_lbl = (By.CSS_SELECTOR, 'h4.required')
    self._add_author_cancel_lnk = (By.CSS_SELECTOR, 'a.author-cancel')
    self._add_author_add_btn = (By.CSS_SELECTOR, 'div.author-form-buttons button')
    self._author_items = (By.CSS_SELECTOR, 'div.authors-overlay-item')
    self._delete_author_div = (By.CLASS_NAME, 'authors-overlay-item--delete')
    self._edit_author = (By.CLASS_NAME, 'fa-pencil')
    self._corresponding = (By.XPATH,
      ".//input[@name='author--published_as_corresponding_author']")

   #POM Actions
  def validate_author_task_styles(self):
    """Validate"""
    authors_text = self._get(self._authors_text)
    assert authors_text.text == (
    "Our criteria for authorship are based on the 'Uniform Requirements for Manuscripts "
    "Submitted to Biomedical Journals: Authorship and Contributorship'. Individuals whose "
    "contributions fall short of authorship should instead be mentioned in the "
    "Acknowledgments. If the article has been submitted on behalf of a consortium, all "
    "author names and affiliations should be listed at the end of the article."
    )
    self.validate_application_ptext(authors_text)
    add_new_author_btn = self._get(self._add_new_author_btn)
    assert 'ADD A NEW AUTHOR' == add_new_author_btn.text, add_new_author_btn.text
    self.validate_primary_big_green_button_style(add_new_author_btn)

  def validate_author_task_action(self):
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
      materials_lbl, writing_lbl = self._gets(self._author_lbls)
    assert corresponding_lbl.text == ('This person will be listed as the corresponding author'
      ' on the published article'), corresponding_lbl.text
    assert deceased_lbl.text == 'This person is deceased'
    other_lbl = self._get(self._author_other_lbl)
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
    time.sleep(5)
    trash = authors[n-1].find_element_by_css_selector('span.fa-trash')
    trash.click()
    # get buttons
    time.sleep(1)
    delete_div = self._get(self._delete_author_div)
    del_message = delete_div.find_element_by_tag_name('p')
    assert del_message.text == 'This will permanently delete the author. Are you sure?'
    # TODO: Check p style, resume this when styles are set.
    cancel_btn, delete_btn  = delete_div.find_elements_by_tag_name('button')
    assert cancel_btn.text == 'CANCEL', cancel_btn.text
    assert delete_btn.text == 'DELETE FOREVER', delete_btn.text
    # TODO: check styles, resume this when styles are set.
    delete_btn.click()
    time.sleep(2)


  def validate_styles(self):
    """Validate all styles for Authors Task"""
    self.validate_author_task_styles()
    self.validate_common_elements_styles()
    return self

  def edit_author(self, author_data):
    """
    Edit the first author in the author task
    :author_data:
    return None
    """
    completed = self.completed_state()
    if completed:
      return None
    author = self._get(self._author_items)
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
    completed = self.completed_state()
    logging.info('Completed State of the Author task is: {0}'.format(completed))
    if not completed:
      self.click_completion_button()
      time.sleep(2)
      try:
        self.validate_completion_error()
      except ElementDoesNotExistAssertionError:
        logging.info('No validation errors completing Author Task')
    time.sleep(2)

  def press_submit_btn(self):
    """Press sidebar submit button"""
    self._get(self._sidebar_submit).click()

  def confirm_submit_btn(self):
    """Press sidebar submit button"""
    self._get(self._submit_confirm).click()
