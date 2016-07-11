#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError, ElementExistsAssertionError
from Base.PostgreSQL import PgSQL
from frontend.Cards.basecard import BaseCard

__author__ = 'jgray@plos.org'


class ReviewerCandidatesCard(BaseCard):
  """
  Page Object Model for the Reviewer Candidates Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(ReviewerCandidatesCard, self).__init__(driver)

    #Locators - Instance members
    self._intro_text = (By.CSS_SELECTOR, 'div.task-main-content > p')
    # APERTA-7177 Typo in class name for the main form
    self._new_candidate_btn = (By.CSS_SELECTOR, 'div.reviewer-canditates-wrapper > button')
    # New Candidate Edit Form
    self._new_candidate_form = (By.CSS_SELECTOR, 'div.reviewer-form')
    self._cand_first_name = (By.CSS_SELECTOR, 'div.first-name')
    self._cand_first_name_label = (By.CSS_SELECTOR, 'div.first-name > div > label')
    self._cand_first_name_input = (By.CSS_SELECTOR, 'div.first-name > input')
    self._cand_middle_initial = (By.CSS_SELECTOR, 'div.middle-name')
    self._cand_middle_initial_label = (By.CSS_SELECTOR, 'div.middle-name > div > label')
    self._cand_middle_initial_input = (By.CSS_SELECTOR, 'div.middle-name > input')
    self._cand_last_name = (By.CSS_SELECTOR, 'div.last-name')
    self._cand_last_name_label = (By.CSS_SELECTOR, 'div.last-name > div > label')
    self._cand_last_name_input = (By.CSS_SELECTOR, 'div.last-name > input')
    self._cand_email = (By.CSS_SELECTOR, 'div.email')
    self._cand_email_label = (By.CSS_SELECTOR, 'div.email > div > label')
    self._cand_email_input = (By.CSS_SELECTOR, 'div.email > input')
    self._cand_title = (By.CSS_SELECTOR, 'div.title')
    self._cand_title_label = (By.CSS_SELECTOR, 'div.title > div > label')
    self._cand_title_input = (By.CSS_SELECTOR, 'div.title > input')
    self._cand_department = (By.CSS_SELECTOR, 'div.department')
    self._cand_department_label = (By.CSS_SELECTOR, 'div.department > div > label')
    self._cand_department_input = (By.CSS_SELECTOR, 'div.department > input')
    # APERTA-7176 the div class name has a typo
    self._cand_institution = (By.CSS_SELECTOR, 'div.insitution')
    self._cand_inst_input = (By.CSS_SELECTOR, 'div.insitution > div > div > div > input')
    self._cand_inst_btn = (By.CSS_SELECTOR, 'div.insitution > div > div > div > button')
    self._cand_recc_or_oppose = (By.CSS_SELECTOR, 'div.question-text')
    self._cand_recc_radio_btn_label = (By.CSS_SELECTOR, 'div.question-text + div > div > label')
    self._cand_recc_radio_btn = (By.CSS_SELECTOR, 'div.question-text + div > div > label > input')
    self._cand_opp_radio_btn_label = (By.CSS_SELECTOR,
                                      'div.question-text + div > div > label + label')
    self._cand_opp_radio_btn = (By.CSS_SELECTOR,
                                'div.question-text + div > div > label + label > input')
    self._cand_reason = (By.CSS_SELECTOR, 'textarea.ember-text-area')
    self._cand_form_cancel = (By.CSS_SELECTOR, 'div.author-form-buttons > a')
    self._cand_form_save = (By.CSS_SELECTOR, 'div.author-form-buttons > button')
    # Candidate View display
    self._cand_entry_view = (By.CSS_SELECTOR,
                             'div.reviewer-canditates-wrapper > div.author-task-item')
    self._cand_view_full_name = (By.CSS_SELECTOR, 'div.author-name.full-name')
    self._cand_view_email = (By.CSS_SELECTOR, 'div.email')
    self._cand_view_decision = (By.CSS_SELECTOR, 'div.decision > span')
    self._cand_view_reason = (By.CSS_SELECTOR, 'div.reason > span')
    self._cand_view_delete = (By.CSS_SELECTOR, 'div.author-task-item-view-actions > span.fa-trash')
    self._cand_view_delete_confirm_text = (By.CSS_SELECTOR, 'div.authors-overlay-item-delete > p')
    self._cand_view_delete_confirm_cancel = (By.CSS_SELECTOR,
                                             'div.authors-overlay-item-delete > button')
    self._cand_view_delete_confirm_delete = (By.CSS_SELECTOR,
                                             'div.authors-overlay-item-delete > button + button')



    #POM Actions

  def validate_styles(self, user_object, paper_id):
    """
    Validate styles in the Title and Abstract Card
    :return: void function
    """
    completed = self.completed_state()
    if completed:
      self.click_completion_button()
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Reviewer Candidates'
    self.validate_application_title_style(card_title)
    intro_text = self._get(self._intro_text)
    self.validate_application_ptext(intro_text)
    assert intro_text.text == 'Use the fields below to give us contact information for each ' \
                              'suggested reviewer, and please provide specific reasons for your ' \
                              'suggestion in the "Reason" box for each person. Please note that ' \
                              'the editorial office may not use your suggestions, but your help ' \
                              'is appreciated and may speed up the selection of appropriate ' \
                              'reviewers.', intro_text.text
    new_cand_btn = self._get(self._new_candidate_btn)
    assert new_cand_btn.text == 'NEW REVIEWER CANDIDATE'
    # validate the extant entry if present
    entry = self._get(self._cand_entry_view)
    if entry:
      full_name = entry.find_element(*self._cand_view_full_name)
      self.validate_application_ptext(full_name)
      assert user_object['name'] == full_name.text, full_name.text
      email = entry.find_element(*self._cand_view_email)
      self.validate_application_ptext(email)
      assert user_object['email'] == email.text, email.text
      decision = entry.find_element(*self._cand_view_decision)
      self.validate_application_ptext(decision)
      stated_reason = entry.find_element(*self._cand_view_reason)
      self.validate_application_ptext(stated_reason)
      self._actions.move_to_element(entry).perform()
      delete_recommendation = entry.find_element(*self._cand_view_delete)
      time.sleep(.5)
      self._actions.move_to_element(delete_recommendation).perform()
      time.sleep(.5)
      delete_recommendation.click()
      # Now need to validate the delete confirmation bits
      confirm_question = self._get(self._cand_view_delete_confirm_text)
      assert 'This will permanently delete the suggested reviewer. Are you sure?' \
             in confirm_question.text, confirm_question.text
      confirm_cancel = self._get(self._cand_view_delete_confirm_cancel)
      # Note that this cancel button is of a style that is different than we use elsewhere, so I
      #  will skip style validation for now - APERTA-7187
      assert 'cancel' in confirm_cancel.text.lower()
      confirm_delete = self._get(self._cand_view_delete_confirm_delete)
      self.validate_green_on_green_button_style(confirm_delete)
      assert 'DELETE FOREVER' == confirm_delete.text
      confirm_cancel.click()
      time.sleep(1)
    # Now validate the new candidate form
    self.validate_primary_big_green_button_style(new_cand_btn)
    self.validate_common_elements_styles(paper_id)
    new_cand_btn.click()
    self._get(self._new_candidate_form)
    fn_element = self._get(self._cand_first_name)
    assert 'required' in fn_element.get_attribute('class'), fn_element.get_attribute('class')
    fn_label = self._get(self._cand_first_name_label)
    self.validate_input_field_inside_label_style(fn_label)
    assert 'First Name' in fn_label.text, fn_label.text
    fn_input = self._get(self._cand_first_name_input)
    self.validate_input_field_style(fn_input)
    assert 'Jane' in fn_input.get_attribute('placeholder'), fn_input.get_attribute('placeholder')

    mi_element = self._get(self._cand_middle_initial)
    assert 'required' not in mi_element.get_attribute('class'), mi_element.get_attribute('class')
    mi_label = self._get(self._cand_middle_initial_label)
    self.validate_input_field_inside_label_style(mi_label)
    assert 'MI' in mi_label.text, mi_label.text
    mi_input = self._get(self._cand_middle_initial_input)
    self.validate_input_field_style(mi_input)
    assert 'M' in mi_input.get_attribute('placeholder'), mi_input.get_attribute('placeholder')

    ln_element = self._get(self._cand_last_name)
    assert 'required' in ln_element.get_attribute('class'), ln_element.get_attribute('class')
    ln_label = self._get(self._cand_last_name_label)
    self.validate_input_field_inside_label_style(ln_label)
    assert 'Last Name' in ln_label.text, ln_label.text
    ln_input = self._get(self._cand_last_name_input)
    self.validate_input_field_style(ln_input)
    assert 'Doe' in ln_input.get_attribute('placeholder'), ln_input.get_attribute('placeholder')

    mail_element = self._get(self._cand_email)
    assert 'required' in mail_element.get_attribute('class'), mail_element.get_attribute('class')
    mail_label = self._get(self._cand_email_label)
    self.validate_input_field_inside_label_style(mail_label)
    assert 'Email' in mail_label.text, mail_label.text
    mail_input = self._get(self._cand_email_input)
    self.validate_input_field_style(mail_input)
    assert 'jane.doe@example.com' in mail_input.get_attribute('placeholder'), \
      mail_input.get_attribute('placeholder')

    title_element = self._get(self._cand_title)
    assert 'required' not in title_element.get_attribute('class'), \
      title_element.get_attribute('class')
    title_label = self._get(self._cand_title_label)
    self.validate_input_field_inside_label_style(title_label)
    assert 'Title' in title_label.text, title_label.text
    title_input = self._get(self._cand_title_input)
    self.validate_input_field_style(title_input)
    assert 'Professor' in title_input.get_attribute('placeholder'), \
      title_input.get_attribute('placeholder')

    dept_element = self._get(self._cand_department)
    assert 'required' not in dept_element.get_attribute('class'), \
      dept_element.get_attribute('class')
    dept_label = self._get(self._cand_department_label)
    self.validate_input_field_inside_label_style(dept_label)
    assert 'Department' in dept_label.text, dept_label.text
    dept_input = self._get(self._cand_department_input)
    self.validate_input_field_style(dept_input)
    assert 'Biology' in dept_input.get_attribute('placeholder'), \
      dept_input.get_attribute('placeholder')

    inst_element = self._get(self._cand_institution)
    assert 'required' not in inst_element.get_attribute('class'), \
      inst_element.get_attribute('class')
    inst_input = self._get(self._cand_inst_input)
    self.validate_input_field_style(inst_input)
    assert 'Institution' in inst_input.get_attribute('placeholder'), \
      inst_input.get_attribute('placeholder')
    self._get(self._cand_inst_btn)

    reviewer_type_question = self._get(self._cand_recc_or_oppose)
    assert 'Are you recommending or opposing this reviewer?' in reviewer_type_question.text, \
      reviewer_type_question.text
    # APERTA-7178
    # assert 'required' in reviewer_type_question.get_attribute('class'), \
    #   reviewer_type_question.get_attribute('class')
    recc_label = self._get(self._cand_recc_radio_btn_label)
    assert 'Recommend' in recc_label.text, recc_label.text
    self.validate_radio_button_label(recc_label)
    self._get(self._cand_recc_radio_btn)
    opp_label = self._get(self._cand_opp_radio_btn_label)
    assert 'Oppose' in opp_label.text, opp_label.text
    self.validate_radio_button_label(opp_label)
    self._get(self._cand_opp_radio_btn)

    opt_reason_field = self._get(self._cand_reason)
    assert 'Optional: reason for recommending or opposing ' \
           'this reviewer' in opt_reason_field.get_attribute('placeholder'), \
      opt_reason_field.get_attribute('placeholder')

    cancel_link = self._get(self._cand_form_cancel)
    assert 'cancel' in cancel_link.text, cancel_link.text
    self.validate_default_link_style(cancel_link)
    save_button = self._get(self._cand_form_save)
    assert 'DONE' in save_button.text, save_button.text
    self.validate_green_on_green_button_style(save_button)

  def check_initial_population(self, decision, reason):
    """
    Verify that the values populated in the form are those were submitted
    :return: void function
    """
    pass
