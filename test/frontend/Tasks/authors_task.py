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

    # Locators - Instance members
    self._authors_text = (By.CSS_SELECTOR,
                          'div.authors-task div.task-disclosure-body div.task-main-content p')
    self._authors_text_link = (
        By.CSS_SELECTOR, 'div.authors-task div.task-disclosure-body div.task-main-content p > a')
    self._authors_note = (By.CSS_SELECTOR,
                          'div.authors-task div.task-disclosure-body div.task-main-content p + p')
    self._add_new_author_btn = (
        By.CSS_SELECTOR, 'div.authors-task div.task-disclosure-body div.task-main-content button')
    self._add_individual_author_link = (By.ID, 'add-new-individual-author-link')
    self._add_group_author_link = (By.ID, 'add-new-group-author-link')
    self._individual_author_edit_label = (By. CSS_SELECTOR,
                                          'div.add-author-form > div > fieldset > legend')
    self._first_lbl = (By.CSS_SELECTOR, 'div.author-name div label')
    self._first_input = (By.CSS_SELECTOR, 'input.author-first')
    self._middle_lbl = (By.CSS_SELECTOR, 'div.author-middle-initial div label')
    self._middle_input = (By.XPATH, ".//div[contains(@class, 'author-middle')]/input")
    self._last_lbl = (By.CSS_SELECTOR, 'div.author-middle-initial + div.author-name div label')
    self._last_input = (By.CSS_SELECTOR, 'input.author-last')
    self._author_inits_field = (By.CSS_SELECTOR, 'div.author-initial')
    self._author_inits_lbl = (By.CSS_SELECTOR, 'div.author-initial > div > label')
    self._author_inits_input = (By.CSS_SELECTOR, 'div.author-initial > div + input')
    self._email_field = (By.XPATH, "//div[@class='flex-group'][2]\
                         /div[@class='flex-element inset-form-control required ']")
    self._email_lbl = (By.XPATH,
                       "//div[@class='flex-group'][2]\
                       /div[@class='flex-element inset-form-control required ']/div/label")
    self._email_input = (By.XPATH,
                         "//div[@class='flex-group'][2]\
                         /div[@class='flex-element inset-form-control required ']/input")
    self._title_lbl = (By.CSS_SELECTOR, 'div.flex-group + div.flex-group div div label')
    self._title_input = (By.CSS_SELECTOR, 'input.author-title')
    self._department_lbl = (By.CSS_SELECTOR, 'div.flex-group + div.flex-group div + div div label')
    self._department_input = (By.CSS_SELECTOR, 'input.author-department')
    self._institution_div = (By.CLASS_NAME, 'did-you-mean-input')
    self._author_lbls = (By.CLASS_NAME, 'question-checkbox')
    self._author_other_lbl = (
        By.CSS_SELECTOR,
        'div.author-contributions div.flex-group + div.flex-group div.flex-element label')
    self._designed_chkbx = (
        By.XPATH,
        ".//input[@name='author--contributions--conceptualization']/following-sibling::span")
    self._author_contrib_lbl = (By.CSS_SELECTOR, 'fieldset.author-contributions legend.required')
    self._add_author_cancel_lnk = (By.CSS_SELECTOR, 'a.author-cancel')
    self._add_author_add_btn = (By.CSS_SELECTOR, 'div.author-form-buttons button')
    self._author_items = (By.CSS_SELECTOR, 'div.author-task-item-view')
    self._delete_author_div = (By.CSS_SELECTOR, 'div.authors-overlay-item-delete')
    self._edit_author = (By.CSS_SELECTOR, 'div.author-name')
    self._corresponding = (
        By.XPATH, ".//input[@name='author--published_as_corresponding_author']")
    self._govt_employee_div = (By.CSS_SELECTOR, 'div.author-government')
    self._govt_employee_question = (By.CSS_SELECTOR, 'div.question-text')
    self._govt_employee_help = (By.CSS_SELECTOR, 'ul.question-help')
    self._govt_employee_radio_yes = (
        By.CSS_SELECTOR, 'div.author-government > div div + ul +div > div > label > input')
    self._govt_employee_radio_no = (
        By.CSS_SELECTOR, 'div.author-government > div div + ul +div > div > label + label > input')
    self._authors_acknowledgement = (By.CLASS_NAME, 'authors-task-acknowledgements')
    self._authors_ack_agree2name = (By.CSS_SELECTOR,
                                    'p.authors-task-acknowledgements + div > label > input')
    self._authors_ack_auth_crit = (By.CSS_SELECTOR,
                                   'p.authors-task-acknowledgements + div + div> label > input')
    self._authors_ack_agree2submit = (
        By.CSS_SELECTOR, 'p.authors-task-acknowledgements + div + div + div > label > input')

  # POM Actions
  def validate_author_task_styles(self):
    """Validate"""
    authors_text = self._get(self._authors_text)
    assert authors_text.text == (
        "Our criteria for authorship are based on the 'Uniform Requirements for Manuscripts "
        "Submitted to Biomedical Journals: Authorship and Contributorship'. Individuals whose "
        "contributions fall short of authorship should instead be mentioned in the "
        "Acknowledgments. If the article has been submitted on behalf of a consortium, all "
        "author names and affiliations should be listed at the end of the article.")
    authors_text_link = self._get(self._authors_text_link)
    assert 'http://www.icmje.org/recommendations/browse/' in authors_text_link.get_attribute('href')
    assert 'roles-and-responsibilities/defining-the-role-of-authors-and-contributors.html' in \
        authors_text_link.get_attribute('href'), authors_text_link.get_attribute('href')
    assert authors_text_link.get_attribute('target') == '_blank', \
        authors_text_link.get_attribute('target')
    authors_note = self._get(self._authors_note)
    assert authors_note.text == 'Note: Ensure the authors are in the correct publication order.', \
        authors_note.text
    self.validate_application_ptext(authors_text)
    self.validate_application_ptext(authors_note)

    add_new_author_btn = self._get(self._add_new_author_btn)
    assert 'ADD A NEW AUTHOR' in add_new_author_btn.text, add_new_author_btn.text
    self.validate_primary_big_green_button_style(add_new_author_btn)
    add_new_author_btn.click()
    add_ind_link = self._get(self._add_individual_author_link)
    assert 'Add Individual Author' in add_ind_link.text, add_ind_link.text
    add_grp_link = self._get(self._add_group_author_link)
    assert 'Add Group Author' in add_grp_link.text, add_grp_link.text
    # Close the menu back up after validating elements
    add_new_author_btn.click()

  def validate_author_task_action(self):
    """Validate working of Author Card. Adds and delete a new individual author"""
    # Add a new author
    self._get(self._add_new_author_btn).click()
    self._get(self._add_individual_author_link).click()
    # Check form elements
    first_lbl = self._get(self._first_lbl)
    first_input = self._get(self._first_input)
    middle_lbl = self._get(self._middle_lbl)
    middle_input = self._get(self._middle_input)
    last_lbl = self._get(self._last_lbl)
    last_input = self._get(self._last_input)
    initials_field = self._get(self._author_inits_field)
    initials_lbl = self._get(self._author_inits_lbl)
    initials_input = self._get(self._author_inits_input)
    email_lbl = self._get(self._email_lbl)
    email_input = self._get(self._email_input)
    title_lbl = self._get(self._title_lbl)
    title_input = self._get(self._title_input)
    department_lbl = self._get(self._department_lbl)
    department_input = self._get(self._department_input)
    assert first_lbl.text == 'First Name', first_lbl.text
    assert first_input.get_attribute('placeholder') == 'Jane'

    # APERTA-6277 This should be leading Cap for all words
    assert middle_lbl.text == 'Middle Name', middle_lbl.text
    assert middle_input.get_attribute('placeholder') == 'M', \
        middle_input.get_attribute('placeholder')

    assert last_lbl.text == 'Last Name', last_lbl.text
    assert last_input.get_attribute('placeholder') == 'Doe', last_input.get_attribute('placeholder')

    assert 'required' in initials_field.get_attribute('class')
    assert initials_lbl.text == 'Author Initial', last_lbl.text

    assert email_lbl.text == 'Email', email_lbl.text
    assert email_input.get_attribute('placeholder') == 'jane.doe@example.com', \
        email_input.get_attribute('placeholder')

    assert title_lbl.text == 'Title', title_lbl.text
    assert title_input.get_attribute('placeholder') == "Professor", \
        title_input.get_attribute('placeholder')

    assert department_lbl.text == 'Department', department_lbl.text
    assert department_input.get_attribute('placeholder') == 'Biology', \
        department_input.get_attribute('placeholder')

    institution_div, sec_institution_div = self._gets(self._institution_div)
    institution_input = institution_div.find_element_by_tag_name('input')
    assert institution_input.get_attribute('placeholder') == '* Institution', \
        institution_input.get_attribute('placeholder')
    institution_icon = institution_div.find_element_by_css_selector('button i')
    assert set(['fa', 'fa-search']) == set(institution_icon.get_attribute('class').split(' '))
    sec_institution_input = sec_institution_div.find_element_by_tag_name('input')
    assert sec_institution_input.get_attribute('placeholder') == 'Secondary Institution'
    sec_institution_icon = sec_institution_div.find_element_by_css_selector('button i')
    assert set(['fa', 'fa-search']) == set(sec_institution_icon.get_attribute('class').split(' '))
    corresponding_lbl, deceased_lbl, conceptualization_lbl, investigation_lbl, visualization_lbl, \
        methodology_lbl, resources_lbl, supervision_lbl, software_lbl, data_curation_lbl, \
        project_admin_lbl, validation_lbl, writing_od_lbl, writing_re_lbl, funding_lbl,  \
        formal_analysis_lbl, agree2name_lbl, auth_criteria_lbl, agree2submit_lbl = \
        self._gets(self._author_lbls)
    assert corresponding_lbl.text == ('This person should be identified as corresponding author'
                                      ' on the published article'), corresponding_lbl.text
    assert deceased_lbl.text == 'This person is deceased'
    assert conceptualization_lbl.text == 'Conceptualization', conceptualization_lbl.text
    assert visualization_lbl.text == 'Visualization', visualization_lbl.text
    assert resources_lbl.text == 'Resources', resources_lbl.text
    assert software_lbl.text == 'Software', software_lbl.text
    assert project_admin_lbl.text == 'Project Administration', project_admin_lbl.text
    assert writing_od_lbl.text == 'Writing - Original Draft', writing_od_lbl.text
    assert funding_lbl.text == 'Funding Acquisition', funding_lbl.text
    assert investigation_lbl.text == 'Investigation', investigation_lbl.text
    assert methodology_lbl.text == 'Methodology', methodology_lbl.text
    assert supervision_lbl.text == 'Supervision', supervision_lbl.text
    assert data_curation_lbl.text == 'Data Curation', data_curation_lbl.text
    assert validation_lbl.text == 'Validation', validation_lbl.text
    assert writing_re_lbl.text == 'Writing - Review and Editing', writing_re_lbl.text
    assert formal_analysis_lbl.text == 'Formal Analysis', formal_analysis_lbl.text

    # Validate the Govt Employee section
    gquest = self._get(self._govt_employee_question)
    assert 'Is this author an employee of the United States Government?' in gquest.text, gquest.text
    ghelp = self._get(self._govt_employee_help)
    assert 'Papers authored by one or more U.S. government employees are not copyrighted, but ' \
           'are licensed under a CC0 Public Domain Dedication, which allows unlimited ' \
           'distribution and reuse of the article for any lawful purpose. This is a legal ' \
           'requirement for U.S. government employees.' in ghelp.text, ghelp.text
    ghelp_link = ghelp.find_element_by_tag_name('a')
    assert ghelp_link.get_attribute('href') == 'https://creativecommons.org/publicdomain/zero/1.0/'
    self._get(self._govt_employee_radio_yes)
    self._get(self._govt_employee_radio_no)

    author_contrib_lbl = self._get(self._author_contrib_lbl)
    assert author_contrib_lbl.text == 'Author Contributions'
    add_author_cancel_lnk = self._get(self._add_author_cancel_lnk)
    add_author_add_btn = self._get(self._add_author_add_btn)
    self.validate_green_on_green_button_style(add_author_add_btn)
    self.validate_default_link_style(add_author_cancel_lnk)
    # fill the data
    first_input.send_keys(author['first'] + Keys.ENTER)
    middle_input.send_keys(author['middle'] + Keys.ENTER)
    last_input.send_keys(author['last'] + Keys.ENTER)
    initials_input.send_keys(author['initials'] + Keys.ENTER)
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
    assert [x for x in all_auth_data if author['first'] in x]
    assert [x for x in all_auth_data if author['last'] in x]
    assert [x for x in all_auth_data if author['email'] in x]
    ack_text = self._get(self._authors_acknowledgement)
    assert "To submit your manuscript, please acknowledge each statement below" in ack_text.text, \
        ack_text.text
    assert agree2name_lbl.text == 'Any persons named in the Acknowledgements section of the ' \
                                  'manuscript, or referred to as the source of a personal ' \
                                  'communication, have agreed to being so named.', \
                                  agree2name_lbl.text
    assert auth_criteria_lbl.text == 'All authors have read, and confirm, that they meet, ICMJE ' \
                                     'criteria for authorship.', auth_criteria_lbl.text
    auth_criteria_link = auth_criteria_lbl.find_element_by_tag_name('a')
    url = '/'.join(['http:/',
                    'www.icmje.org',
                    'recommendations',
                    'browse',
                    'roles-and-responsibilities',
                    'defining-the-role-of-authors-and-contributors.html'])
    assert auth_criteria_link.get_attribute('href') == url
    assert agree2submit_lbl.text == 'All contributing authors are aware of and agree to the ' \
                                    'submission of this manuscript.', agree2submit_lbl.text

  def validate_delete_author(self):
    """Check deleting an author from author card"""
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
    self._actions.move_to_element(authors[n - 1]).perform()
    time.sleep(5)
    trash = authors[n - 1].find_element_by_css_selector('span.fa-trash')
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

  def validate_styles(self):
    """Validate all styles for Authors Task"""
    self.validate_author_task_styles()
    self.validate_common_elements_styles()
    return self

  def edit_author(self, author_data):
    """
    Edit the first author in the author task
    :param author_data: data sourced from Resources.py used to fill out author card
    return None
    """
    completed = self.completed_state()
    if completed:
      return None
    author_div = self._get(self._author_items)
    self._actions.move_to_element(author_div).perform()
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

    # Need to complete the remaining required elements to successfully complete this card.
    author_inits_input = self._get(self._author_inits_input)
    author_inits_input.send_keys('AA')
    self._get(self._govt_employee_radio_no).click()
    self._get(self._authors_ack_agree2name).click()
    self._get(self._authors_ack_auth_crit).click()
    self._get(self._authors_ack_agree2submit).click()

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
