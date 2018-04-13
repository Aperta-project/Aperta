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

import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  name: DS.attr('string'),
  category: DS.attr('string'),
  to: DS.attr('string'),
  subject: DS.attr('string'),
  body: DS.attr('string'),
  journalId: DS.attr('number'),
  mergeFields: DS.attr(),
  scenario: DS.attr('string'),
  cc: DS.attr('string'),
  bcc: DS.attr('string'),

  subjectErrors: [],
  bodyErrors: [],
  ccErrors: [],
  bccErrors: [],
  nameError: '',

  nameEmpty: Ember.computed.empty('name'),
  subjectErrorPresent: Ember.computed.notEmpty('subjectErrors'),
  bodyErrorPresent: Ember.computed.notEmpty('bodyErrors'),
  nameErrorPresent: Ember.computed.notEmpty('nameError'),
  ccErrorPresent: Ember.computed.notEmpty('ccErrors'),
  bccErrorPresent: Ember.computed.notEmpty('bccErrors'),
  hasErrors: Ember.computed.or('subjectErrorPresent', 'bodyErrorPresent', 'nameErrorPresent', 'ccErrorPresent', 'bccErrorPresent'),

  clearErrors() {
    this.setProperties({
      subjectErrors: [],
      bodyErrors: [],
      ccErrors: [],
      bccErrors: []
    });
  },

  parseErrors(error) {
    const subjectErrors = error.errors.filter((e) => e.source.pointer.includes('subject'));
    const bodyErrors = error.errors.filter((e) => e.source.pointer.includes('body'));
    const nameError = error.errors.filter(e => e.source.pointer.includes('name'));
    const ccErrors = error.errors.filter(e => e.source.pointer.endsWith('/cc'));
    const bccErrors = error.errors.filter(e => e.source.pointer.endsWith('/bcc'));
    if (subjectErrors.length) {
      this.set('subjectErrors', subjectErrors.map(s => s.detail));
    }
    if (bodyErrors.length) {
      this.set('bodyErrors', bodyErrors.map(b => b.detail));
    }
    if (nameError.length) {
      this.set('nameError', nameError.map(n => n.detail));
    }
    if (ccErrors.length) {
      this.set('ccErrors', ccErrors.map(err => err.detail));
    }
    if (bccErrors.length) {
      this.set('bccErrors', bccErrors.map(err => err.detail));
    }
  },

  preview() {
    let data = _.pick(this.serialize(), ['body', 'subject', 'cc', 'bcc']);
    let modelName = this.constructor.modelName;
    let adapter = this.store.adapterFor(modelName);
    return adapter.preview(this.get('id'), data);
  }
});
