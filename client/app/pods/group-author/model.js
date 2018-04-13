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

import Ember from 'ember';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/pods/nested-question-owner/model';
import Answerable from 'tahi/mixins/answerable';

const { attr, belongsTo } = DS;

export const contributionIdents = [
  'group-author--contributions--conceptualization',
  'group-author--contributions--investigation',
  'group-author--contributions--visualization',
  'group-author--contributions--methodology',
  'group-author--contributions--resources',
  'group-author--contributions--supervision',
  'group-author--contributions--software',
  'group-author--contributions--data-curation',
  'group-author--contributions--project-administration',
  'group-author--contributions--validation',
  'group-author--contributions--writing-original-draft',
  'group-author--contributions--writing-review-and-editing',
  'group-author--contributions--funding-acquisition',
  'group-author--contributions--formal-analysis',
];


export default NestedQuestionOwner.extend(Answerable, {
  paper: belongsTo('paper', { async: false }),
  coAuthorStateModifiedBy: belongsTo('user'),

  contactFirstName: attr('string'),
  contactLastName: attr('string'),
  contactMiddleName: attr('string'),
  contactEmail: attr('string'),

  coAuthorState: attr('string'),
  coAuthorStateModifiedAt: attr('date'),

  confirmedAsCoAuthor: Ember.computed.equal('coAuthorState', 'confirmed'),
  refutedAsCoAuthor: Ember.computed.equal('coAuthorState', 'refuted'),

  name: attr('string'),
  initial: attr('string'),

  position: attr('number'),

  displayName: Ember.computed.alias('name'),

  validations: {
    'name': ['presence'],
    'contactFirstName': ['presence'],
    'contactLastName': ['presence'],
    'contactEmail': ['presence', 'email'],
   'government': [{
      type: 'presence',
      message: 'A selection must be made',
      validation() {
        const author = this.get('object');
        const answer = author
              .answerForQuestion('group-author--government-employee')
              .get('value');

        return answer === true || answer === false;
      }
    }],
    'contributions': [{
      type: 'presence',
      message: 'One must be selected',
      validation() {
        // NOTE: the validations for contributions is the same as in author.js. If you make changes
        // here please also check to see if changes need to be made there.
        const author = this.get('object');
        return _.some(contributionIdents, (ident) => {
          let answer = author.answerForQuestion(ident);
          Ember.assert(`Tried to find an answer for question with ident, ${ident}, but none was found`, answer);
          return answer.get('value');
        });
      }
    }]
  }
});
