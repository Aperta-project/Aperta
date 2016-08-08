#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time
import random

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from frontend.Tasks.basetask import BaseTask
from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Resources import author, group_author

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

    self._author_items = (By.CSS_SELECTOR, 'div.author-task-item-view')
    self._delete_author_div = (By.CSS_SELECTOR, 'div.authors-overlay-item-delete')
    self._edit_author = (By.CSS_SELECTOR, 'div.author-name')

    # Final Acknowledgements - Global
    self._authors_acknowledgement = (By.CLASS_NAME, 'authors-task-acknowledgements')
    self._authors_ack_agree2name = (By.CSS_SELECTOR,
                                    'p.authors-task-acknowledgements + div > label > input')
    self._authors_ack_auth_crit = (By.CSS_SELECTOR,
                                   'p.authors-task-acknowledgements + div + div> label > input')
    self._authors_ack_agree2submit = (
        By.CSS_SELECTOR, 'p.authors-task-acknowledgements + div + div + div > label > input')

    # Individual Author Form
    self._individual_author_form = (By.CLASS_NAME, 'individual-author-form')
    self._individual_author_edit_label = (By. CSS_SELECTOR,
                                          'div.individual-author-form > div > fieldset > legend')
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

    # Group Author Form
    self._group_author_form = (By.CLASS_NAME, 'group-author-form')
    self._group_author_edit_label = (By. CSS_SELECTOR,
                                     'div.group-author-form > div > fieldset > legend')
    self._group_name_lbl = (
        By.CSS_SELECTOR, 'div.group-author-form > div > fieldset > div > div > div > label')
    self._group_name_input = (By.CSS_SELECTOR, 'input.group-name')
    self._group_inits_lbl = (
        By.CSS_SELECTOR, 'div.group-author-form > div > fieldset > div > div + div > div > label')
    self._group_inits_input = (By.CSS_SELECTOR, 'input.group-initial')
    self._group_contact_intro_text = (
        By.CSS_SELECTOR, 'div.group-author-form > div > fieldset + fieldset > legend')
    self._gfirst_lbl = (By.CSS_SELECTOR, 'div.author-name div label')
    self._gfirst_input = (By.CSS_SELECTOR, 'input.contact-first')
    self._gmiddle_lbl = (By.CSS_SELECTOR, 'div.author-middle-name div label')
    self._gmiddle_input = (By.XPATH, ".//div[contains(@class, 'author-middle-name')]/input")
    self._glast_lbl = (By.CSS_SELECTOR, 'div.author-middle-name + div.author-name div label')
    self._glast_input = (By.CSS_SELECTOR, 'input.contact-last')
    self._gemail_field = (By.XPATH, "//div[@class='flex-group'][2]\
                         /div[@class='flex-element inset-form-control required ']")
    self._gemail_lbl = (By.XPATH,
                        "//div[@class='flex-group'][2]\
                        /div[@class='flex-element inset-form-control required ']/div/label")
    self._gemail_input = (By.CSS_SELECTOR, 'input.contact-email')
    self._gauthor_lbls = (By.CLASS_NAME, 'question-checkbox')
    self._gauthor_other_lbl = (
        By.CSS_SELECTOR,
        'div.author-contributions div.flex-group + div.flex-group div.flex-element label')
    self._gdesigned_chkbx = (
        By.XPATH,
        ".//input[@name='author--contributions--conceptualization']/following-sibling::span")
    self._gauthor_contrib_lbl = (By.CSS_SELECTOR, 'fieldset.author-contributions legend.required')
    self._gauthor_contrib_heading_link = (By.CSS_SELECTOR,
                                          'fieldset.author-contributions legend.required > a')
    self._ggovt_employee_div = (By.CSS_SELECTOR, 'div.author-government')
    self._ggovt_employee_question = (By.CSS_SELECTOR, 'div.question-text')
    self._ggovt_employee_help = (By.CSS_SELECTOR, 'ul.question-help')
    self._ggovt_employee_radio_yes = (
        By.CSS_SELECTOR, 'div.author-government > div div + ul +div > div > label > input')
    self._ggovt_employee_radio_no = (
        By.CSS_SELECTOR, 'div.author-government > div div + ul +div > div > label + label > input')

    # Form Action Buttons
    self._add_author_cancel_lnk = (By.CSS_SELECTOR, 'a.author-cancel')
    self._add_author_add_btn = (By.CSS_SELECTOR, 'div.author-form-buttons > button')

  # POM Actions
  def validate_author_task_styles(self):
    """Validate"""
    authors_text = self._get(self._authors_text)
    assert authors_text.text == (
        "Our criteria for authorship are based on the 'Uniform Requirements for Manuscripts "
        "Submitted to Biomedical Journals: Authorship and Contributorship'. Individuals whose "
        "contributions fall short of authorship should instead be mentioned in the "
        "Acknowledgments. If the article has been submitted on behalf of a consortium, all "
        "author names and affiliations should be listed at the end of the article."), \
        authors_text.text
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
    completion_btn = self._get(self._completion_button)
    self._actions.move_to_element(completion_btn).perform()
    add_new_author_btn.click()
    self.validate_individual_author_form_styles(add_new_author_btn, add_ind_link)
    self.validate_group_author_form_styles(add_new_author_btn, add_grp_link)

  def validate_individual_author_form_styles(self, add_new_author_btn, add_ind_link):
    """
    Validates the elements and styles of the individual author form
    :param add_new_author_btn: the WebDriver element for the Add New Author button
    :param add_ind_link: the WebDriver element for the Add New Individual Author link
    :return: void function
    """
    add_new_author_btn.click()
    add_ind_link.click()
    ind_auth_form = self._get(self._individual_author_form)
    ind_auth_form_title = self._get(self._individual_author_edit_label)
    assert 'Individual Author' in ind_auth_form_title.text
    first_lbl = self._get(self._first_lbl)
    first_input = self._get(self._first_input)
    middle_lbl = self._get(self._middle_lbl)
    middle_input = self._get(self._middle_input)
    last_lbl = self._get(self._last_lbl)
    last_input = self._get(self._last_input)
    initials_field = self._get(self._author_inits_field)
    initials_lbl = self._get(self._author_inits_lbl)
    self._get(self._author_inits_input)
    email_lbl = self._get(self._email_lbl)
    email_input = self._get(self._email_input)
    title_lbl = self._get(self._title_lbl)
    title_input = self._get(self._title_input)
    department_lbl = self._get(self._department_lbl)
    department_input = self._get(self._department_input)
    assert first_lbl.text == 'First Name', first_lbl.text
    assert first_input.get_attribute('placeholder') == 'Jane'

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
        formal_analysis_lbl = ind_auth_form.find_elements_by_class_name('question-checkbox')

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

    # Validate the global ending elements
    agree2name_lbl, auth_criteria_lbl, agree2submit_lbl = \
        self._gets(self._author_lbls)[-3], \
        self._gets(self._author_lbls)[-2], \
        self._gets(self._author_lbls)[-1]
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
    govt_div = self._get(self._govt_employee_div)
    self._actions.move_to_element(govt_div).perform()
    add_author_cancel_lnk.click()

  def validate_group_author_form_styles(self, add_new_author_btn, add_grp_link):
    """
    Validates the elements and styles of the group author form
    :param add_new_author_btn: the WebDriver element for the Add New Author button
    :param add_grp_link: the WebDriver element for the Add New Group Author link
    :return: void function
    """
    add_new_author_btn.click()
    add_grp_link.click()
    grp_auth_form = self._get(self._group_author_form)
    grp_auth_form_title = self._get(self._group_author_edit_label)
    assert 'Group Author' in grp_auth_form_title.text, grp_auth_form_title.text

    group_name_lbl = self._get(self._group_name_lbl)
    assert group_name_lbl.text == 'Group Name', group_name_lbl.text
    group_name_input = self._get(self._group_name_input)
    assert group_name_input.get_attribute('placeholder') == \
        'Scientific Association of North America', group_name_input.get_attribute('placeholder')
    group_inits_lbl = self._get(self._group_inits_lbl)
    assert group_inits_lbl.text == 'Group Initial', group_inits_lbl.text
    group_inits_input = self._get(self._group_inits_input)
    assert group_inits_input.get_attribute('placeholder') == \
        'SANA', group_name_input.get_attribute('placeholder')

    group_contact_preamble = self._get(self._group_contact_intro_text)
    assert 'Please provide information of a contact person. ' \
           '(This information will not be published)' in group_contact_preamble.text, \
           group_contact_preamble.text

    first_lbl = self._get(self._gfirst_lbl)
    assert first_lbl.text == 'First Name', first_lbl.text
    first_input = self._get(self._gfirst_input)
    assert first_input.get_attribute('placeholder') == 'Jane', \
        first_input.get_attribute('placeholder')
    middle_lbl = self._get(self._gmiddle_lbl)
    assert middle_lbl.text == 'Middle Name', middle_lbl.text
    middle_input = self._get(self._gmiddle_input)
    assert middle_input.get_attribute('placeholder') == 'M', \
        first_input.get_attribute('placeholder')
    last_lbl = self._get(self._glast_lbl)
    assert last_lbl.text == 'Last Name', last_lbl.text
    last_input = self._get(self._glast_input)
    assert last_input.get_attribute('placeholder') == 'Doe', \
        last_input.get_attribute('placeholder')
    email_lbl = self._get(self._gemail_lbl)
    assert email_lbl.text == 'Email', email_lbl.text
    email_input = self._get(self._gemail_input)
    assert email_input.get_attribute('placeholder') == 'jane.doe@example.com', \
        email_input.get_attribute('placeholder')
    author_contributions_heading = self._get(self._gauthor_contrib_lbl)
    assert 'Author Contributions' in author_contributions_heading.text, \
        author_contributions_heading.text
    author_contribs_heading_link = self._get(self._gauthor_contrib_heading_link)
    assert author_contribs_heading_link.text == 'Contributions', author_contribs_heading_link.text
    assert author_contribs_heading_link.get_attribute('href') == \
        'http://www.cell.com/pb/assets/raw/shared/guidelines/CRediT-Taxonomy.pdf'
    assert author_contribs_heading_link.get_attribute('target') == '_blank'
    conceptualization_lbl, investigation_lbl, visualization_lbl, \
        methodology_lbl, resources_lbl, supervision_lbl, software_lbl, data_curation_lbl, \
        project_admin_lbl, validation_lbl, writing_od_lbl, writing_re_lbl, funding_lbl,  \
        formal_analysis_lbl = grp_auth_form.find_elements_by_class_name('question-checkbox')

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
    gquest = self._get(self._ggovt_employee_question)
    assert 'Is this group a United States Government agency, department or organization?' in \
        gquest.text, gquest.text
    ghelp = self._get(self._ggovt_employee_help)
    assert 'Papers authored by U.S. government organizations are not copyrighted, but are ' \
           'licensed under a CC0 Public Domain Dedication, which allows unlimited distribution ' \
           'and reuse of the article for any lawful purpose. This is a legal requirement for ' \
           'U.S. government employees.' in ghelp.text, ghelp.text
    ghelp_link = ghelp.find_element_by_tag_name('a')
    assert ghelp_link.get_attribute('href') == 'https://creativecommons.org/publicdomain/zero/1.0/'
    self._get(self._ggovt_employee_radio_yes)
    self._get(self._ggovt_employee_radio_no)
    # Form Action Buttons
    add_author_cancel_lnk = self._get(self._add_author_cancel_lnk)
    add_author_add_btn = self._get(self._add_author_add_btn)
    self.validate_green_on_green_button_style(add_author_add_btn)
    self.validate_default_link_style(add_author_cancel_lnk)
    # Note: the acknowledgements were validated in the individual form element/styling method
    # Close the form when done validating
    add_author_cancel_lnk = self._get(self._add_author_cancel_lnk)
    add_author_cancel_lnk.click()

  def add_individual_author_task_action(self):
    """Validate working of Author Card. Adds new individual author"""
    logging.info('Adding a new author')
    # Add a new author
    logging.info('Opening the individual author form')
    self._get(self._add_new_author_btn).click()
    self._get(self._add_individual_author_link).click()
    # Check form elements
    first_input = self._get(self._first_input)
    middle_input = self._get(self._middle_input)
    last_input = self._get(self._last_input)
    initials_input = self._get(self._author_inits_input)
    email_input = self._get(self._email_input)
    title_input = self._get(self._title_input)
    department_input = self._get(self._department_input)
    institution_div, sec_institution_div = self._gets(self._institution_div)
    institution_input = institution_div.find_element_by_tag_name('input')
    sec_institution_input = sec_institution_div.find_element_by_tag_name('input')
    govt_yes = self._get(self._govt_employee_radio_yes)
    govt_no = self._get(self._govt_employee_radio_no)

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

    govt_choice = random.choice(['Yes', 'No'])
    logging.info('Selecting Gov\'t Choice {0}'.format(govt_choice))
    govt_div = self._get(self._govt_employee_div)
    self._actions.move_to_element(govt_div).perform()
    if govt_choice == 'Yes':
      govt_yes.click()
    else:
      govt_no.click()
    time.sleep(1)
    add_author_add_btn = self._get(self._add_author_add_btn)
    add_author_add_btn.click()
    # Check if data is there
    time.sleep(3)
    authors = self._gets(self._author_items)
    all_auth_data = [x.text for x in authors]
    assert [x for x in all_auth_data if author['first'] in x], u'{0} not in {1}'.format(
        author['first'], all_auth_data)
    assert [x for x in all_auth_data if author['last'] in x], u'{0} not in {1}'.format(
        author['last'], all_auth_data)
    assert [x for x in all_auth_data if author['email'] in x], u'{0} not in {1}'.format(
        author['email'], all_auth_data)

  def add_group_author_task_action(self):
    """Validate working of Author Card. Adds new group author"""
    logging.info('Adding a new group author')
    # Add a new author
    logging.info('Opening the group author form')
    self._get(self._add_new_author_btn).click()
    self._get(self._add_group_author_link).click()
    # Check form elements
    group_name_input = self._get(self._group_name_input)
    group_inits_input = self._get(self._group_inits_input)
    first_input = self._get(self._gfirst_input)
    middle_input = self._get(self._gmiddle_input)
    last_input = self._get(self._glast_input)
    email_input = self._get(self._gemail_input)
    govt_yes = self._get(self._ggovt_employee_radio_yes)
    govt_no = self._get(self._ggovt_employee_radio_no)

    # fill the data
    group_name_input.send_keys(group_author['group_name'] + Keys.ENTER)
    group_inits_input.send_keys(group_author['group_inits'] + Keys.ENTER)
    first_input.send_keys(group_author['first'] + Keys.ENTER)
    middle_input.send_keys(group_author['middle'] + Keys.ENTER)
    last_input.send_keys(group_author['last'] + Keys.ENTER)
    email_input.send_keys(group_author['email'] + Keys.ENTER)

    govt_choice = random.choice(['Yes', 'No'])
    logging.info('Selecting Gov\'t Choice {0}'.format(govt_choice))
    govt_div = self._get(self._govt_employee_div)
    self._actions.move_to_element(govt_div).perform()
    if govt_choice == 'Yes':
      govt_yes.click()
    else:
      govt_no.click()
    time.sleep(1)
    add_author_add_btn = self._get(self._add_author_add_btn)
    add_author_add_btn.click()
    # Check if data is there
    time.sleep(3)
    authors = self._gets(self._author_items)
    for item in authors:
      logging.info(item.text)
    all_auth_data = [x.text for x in authors]
    assert [x for x in all_auth_data if group_author['group_name'] in x]
    assert [x for x in all_auth_data if group_author['email'] in x]

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
    time.sleep(1)
    govt_employee_question = self._get(self._govt_employee_question)
    self._actions.move_to_element(govt_employee_question).perform()
    if 'government' in author_data and author_data['government']:
      self._get(self._govt_employee_radio_yes).click()
    else:
      self._get(self._govt_employee_radio_no).click()
    self._get(self._authors_ack_agree2name).click()
    self._get(self._authors_ack_auth_crit).click()
    self._get(self._authors_ack_agree2submit).click()

    title_input = self._get(self._title_input)
    department_input = self._get(self._department_input)
    institutions = self._gets(self._institution_div)
    if len(institutions) == 2:
      institution_div = institutions[0]
      institution_input = institution_div.find_element_by_tag_name('input')
      institution_input.clear()
      institution_input.send_keys(author_data['institution'] + Keys.ENTER)
      # Time to look for institutions to fill the drop down options
      time.sleep(5)
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
    author_inits_input.send_keys(author_data['initials'])
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
