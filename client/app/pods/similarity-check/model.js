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
import { similarityCheckReportPath } from 'tahi/utils/api-path-helpers';

export default DS.Model.extend({
  versionedText: DS.belongsTo('versioned-text'),
  paper: DS.belongsTo('paper'),
  state: DS.attr('string'),
  errorMessage: DS.attr('string'),
  updatedAt: DS.attr('date'),
  ithenticateScore: DS.attr('string'),
  dismissed: DS.attr('boolean'),

  text: Ember.computed.reads('errorMessage'),
  type: 'error',
  failed: Ember.computed.equal('state', 'failed'),
  succeeded: Ember.computed.equal('state', 'report_complete'),
  incomplete: Ember.computed('state', function() {
    let state = this.get('state');
    return state !== 'report_complete' && state !== 'failed';
  }),

  reportPath: Ember.computed('id', function() {
    return similarityCheckReportPath(this.get('id'));
  }),

  humanReadableState: Ember.computed('state', function() {
    return {
      needs_upload: 'is pending',
      waiting_for_report: 'is in progress',
      failed: 'has failed',
      report_complete: 'succeeded'
    }[this.get('state')];
  })
});
