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
import SnapshotAttachment from 'tahi/pods/snapshot/attachment/model';

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  nestedLevel: 1,
  classNames: ['snapshot'],
  classNameBindings: ['levelClassName'],

  primarySnapshot: Ember.computed('snapshot1', 'snapshot2', function(){
    return (this.get('snapshot1') || this.get('snapshot2'));
  }),
  generalCase: Ember.computed.not('specialCase'),
  specialCase: Ember.computed.or(
    'authorsTask', 'funder'),

  authorsTask: Ember.computed.equal('primarySnapshot.name', 'authors-task'),
  boolean: Ember.computed.equal('primarySnapshot.type', 'boolean'),
  booleanQuestion: Ember.computed.equal(
    'primarySnapshot.value.answer_type',
    'boolean'),
  figure: Ember.computed.equal('primarySnapshot.name', 'figure'),
  supportingInformationFile: Ember.computed.equal('primarySnapshot.name', 'supporting-information-file'),
  file1: Ember.computed('snapshot1', function() {
    return SnapshotAttachment.create({attachment: this.get('snapshot1')});
  }),
  file2: Ember.computed('snapshot2', function() {
    return SnapshotAttachment.create({attachment: this.get('snapshot2')});
  }),
  funder: Ember.computed.equal('primarySnapshot.name', 'funder'),
  id: Ember.computed.equal('primarySnapshot.name', 'id'),
  integer: Ember.computed.equal('primarySnapshot.type', 'integer'),

  question: Ember.computed('primarySnapshot.type', 'primarySnapshot.value.answer_type', function() {
    return this.get('primarySnapshot.type') === 'question'
      && Ember.isPresent(this.get('primarySnapshot.value.answer_type'));
  }),

  supportingInfo: Ember.computed.equal(
    'primarySnapshot.name',
    'supporting-information-task'),
  text: Ember.computed.equal('primarySnapshot.type', 'text'),
  textOrInteger: Ember.computed.or('integer', 'text'),
  userEnteredValue: Ember.computed.not('id'),

  hasQuestion1Title: Ember.computed.notEmpty('snapshot1.value.title'),
  hasQuestion2Title: Ember.computed.notEmpty('snapshot2.value.title'),
  diffQuestionTitles: Ember.computed.and('hasQuestion1Title', 'hasQuestion2Title'),

  raw: Ember.computed('primarySnapshot.type', function(){
    return this.get('textOrInteger') && this.get('userEnteredValue');
  }),

  children: Ember.computed(
    'snapshot1.children',
    'snapshot2.children',
    function(){
      return _.zip(
        this.get('snapshot1.children') || [],
        this.get('snapshot2.children') || []);
    }
  ),

  levelClassName: Ember.computed('nestedLevel', function(){
    return `nested-level-${this.get('nestedLevel')}`;
  })
});
