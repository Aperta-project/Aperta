/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import DATA from 'tahi/plos-billing-form-data';
import questionValidations from 'tahi/billing-task-validations';

const {
  computed,
  inject: { service }
} = Ember;

export default TaskComponent.extend({
  classNames: ['billing-task'],
  questionValidations: questionValidations,
  validateData() {
    this.validateQuestions();
  },

  init() {
    this._super(...arguments);
    let countries = this.get('countries');
    countries.get('fetch').perform();

    this.get('institutionalAccounts').fetch();
  },

  countries: service(),
  ringgold: [],
  institutionalAccounts: service(),
  states:    DATA.states,
  pubFee:    DATA.pubFee,
  journals:  DATA.journals,
  previousJournals:  DATA.previousJournals,
  responses: DATA.responses,
  groupOneAndTwoCountries: DATA.groupOneAndTwoCountries,

  formattedCountries: computed('countries.data', function() {
    return this.get('countries.data').map(function(c) {
      return { id: c, text: c };
    });
  }),

  journalName: 'PLOS One',
  inviteCode: '',
  endingComments: '',

  feeMessage: computed('journalName', function() {
    return 'The fee for publishing in ' + this.get('journalName') +
      ' is $' + this.get('pubFee');
  }),

  selectedRinggold: null,
  selectedPaymentMethod: computed('model.nestedQuestionAnswers.[]', function(){
    return this.get('task')
               .answerForQuestion('plos_billing--payment_method')
               .get('value');
  }),

  agreeCollections: false,

  affiliation1Question: computed('model.nestedQuestions.[]', function() {
    return this.get('task').findQuestion('plos_billing--affiliation1');
  }),

  affiliation2Question: computed('model.nestedQuestions.[]', function() {
    return this.get('task').findQuestion('plos_billing--affiliation2');
  }),

  // institution-search component expects data to be
  // hash with name property
  affiliation1Proxy: computed('affiliation1Question', function(){
    const question = this.get('affiliation1Question');
    const answer = question.answerForOwner(this.get('task'));
    if(answer.get('wasAnswered')) {
      return { name: answer.get('value') };
    }
  }),

  // institution-search component expects data to be hash
  // with name property
  affiliation2Proxy: computed('affiliation2Question', function(){
    const question = this.get('affiliation2Question');
    const answer = question.answerForOwner(this.get('task'));
    if(answer.get('wasAnswered')) {
      return { name: answer.get('value') };
    }
  }),

  setAffiliationAnswer(index, answerValue) {
    const question = this.get('affiliation' + index + 'Question');
    const answer = question.answerForOwner(this.get('task'));

    if(typeof answerValue === 'string') {
      answer.set('value', answerValue);
    } else if(typeof answerValue === 'object') {
      answer.set('value', answerValue.name);
      answer.set('additionalData', {
        answer: answerValue.name,
        additionalData: answerValue
      });
    }

    answer.save();
  },

  actions: {
    paymentMethodSelected(selection) {
      this.set('selectedPaymentMethod', selection.id);
    },

    affiliation1Selected(answer) {
      this.setAffiliationAnswer('1', answer);

      this.validateQuestion(
        this.get('affiliation1Question.ident'),
        answer
      );
    },

    affiliation2Selected(answer) { this.setAffiliationAnswer('2', answer); }
  }
});
