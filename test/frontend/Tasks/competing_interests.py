#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random

from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask

__author__ = 'jgray@plos.org'


class CompetingInterestsTask(BaseTask):
    """
    Page Object Model for Competing Interests Card in Paper Viewer View
    """

    def __init__(self, driver):
        super(CompetingInterestsTask, self).__init__(driver)

        # Locators - Instance members
        self._intro_text = (By.CSS_SELECTOR, '.question-text')
        self._intro_text_link = (By.CSS_SELECTOR, '.question-text > a')
        self._yes_radio = (By.CSS_SELECTOR, 'label > input')
        self._yes_label = (By.XPATH, "//*[@class='card-form-label'][contains(text(),'Yes')]")
        self._no_radio = (By.CSS_SELECTOR, 'div.card-radio + div.card-radio > label > input')
        self._no_label = (By.XPATH, "//*[@class='card-form-label'][contains(text(),'No')]")
        self._yes_subform = (By.CSS_SELECTOR, '.card-content-display-children')
        # Note that the following element is not unique in the card and thus must be used in a
        #     find_element sequence under the subform locator above
        self._yes_subform_instructs = (By.CSS_SELECTOR, '.card-form-text')
        self._no_statement = (By.CSS_SELECTOR, '.card-content-view-text')

    # POM Actions
    def validate_styles(self):
        """
        Validate elements and styles in the Competing Interests Card in paper viewer context
        """
        intro_text = self._get(self._intro_text)
        self.validate_card_question_text(intro_text)
        assert 'You are responsible for recognizing and disclosing on behalf of all authors any ' \
               'competing interest that could be perceived to bias their work, acknowledging all ' \
               'financial support and any other relevant financial or non-financial competing ' \
               'interests.' in intro_text.text, intro_text.text
        assert 'Do any authors of this manuscript have competing interests (as described in the ' \
               'PLOS Policy on Declaration and Evaluation of Competing Interests)?' in \
               intro_text.text, intro_text.text
        question_link = self._get(self._intro_text_link)
        assert question_link.text == 'PLOS Policy on Declaration and Evaluation of Competing ' \
                                     'Interests', question_link.text
        assert question_link.get_attribute('href') == \
            'http://journals.plos.org/plosbiology/s/competing-interests', \
            question_link.get_attribute('href')
        assert question_link.get_attribute('target') == '_blank', \
            question_link.get_attribute('target')
        yes_radio = self._get(self._yes_radio)
        assert not yes_radio.is_selected()
        yes_label = self._get(self._yes_label)
        self.validate_checkbox_label(yes_label)
        no_radio = self._get(self._no_radio)
        assert not no_radio.is_selected()
        no_label = self._get(self._no_label)
        self.validate_checkbox_label(no_label)
        no_radio.click()
        no_statement = self._get(self._no_statement)
        assert no_statement.text == 'Your competing interests statement will appear as: "The ' \
                                    'authors have declared that no competing interests exist." ' \
                                    'Please note that if your manuscript is accepted, this ' \
                                    'statement will be published.', no_statement.text
        self.validate_application_body_text(no_statement)
        yes_radio.click()
        subform = self._get(self._yes_subform)
        subform_instructs = subform.find_element(*self._yes_subform_instructs)
        assert "Please provide details about any and all competing interests in the box below. " \
               "Your response should begin with this statement: \"I have read the journal's " \
               "policy and the authors of this manuscript have the following competing " \
               "interests.\"\n\nPlease note that if your manuscript is accepted, this statement " \
               "will be published." in subform_instructs.text, subform_instructs.text
        rte_id, iframe = self.get_rich_text_editor_instance('competing_interests--statement')
        assert iframe, 'No "Yes" Subform input area found in Competing Interests card'
        self.tmce_set_rich_text(iframe, content='Kilroy was here.')
        self.pause_to_save()

    def complete_form(self, choice: str) -> tuple:
        """
        Filling out the competing interests card with specified top level selection
        :param choice: If supplied, will fill out the form accordingly, else, will make a random
        choice. Expected 'Yes' or 'No' (case sensitive) if supplied
        """
        content = str()
        yes_radio = self._get(self._yes_radio)
        no_radio = self._get(self._no_radio)
        if not choice:
            choice = random.choice(['Yes', 'No'])
            logging.info('Randomly selected Competing Interest Choice is: {0}'.format(choice))
        if choice == 'Yes':
            yes_radio.click()
            rte_id, iframe = self.get_rich_text_editor_instance('competing_interests--statement')
            assert iframe, 'No "Yes" Subform input area found in Competing Interests card'
            content = 'Kilroy was here - and said there was a conflict!.'
            self.tmce_set_rich_text(iframe, content=content)
            self.pause_to_save()
        elif choice == 'No':
            no_radio.click()
        else:
            raise ValueError('The choice passed into the complete_form method is invalid: '
                             '{0}. Note that choice is case sensitive.'.format(choice))
        self.pause_to_save()
        return choice, content
