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
  paper: DS.belongsTo('paper', { async: true }),
  task: DS.belongsTo('task', {
    inverse: 'exportDeliveries',
    polymorphic: true
  }),
  state: DS.attr('string'),
  errorMessage: DS.attr('string'),
  createdAt: DS.attr('date'),
  destination: DS.attr('string'),

  failed: Ember.computed.equal('state', 'failed'),
  succeeded: Ember.computed('state', function() {
    let state = this.get('state');
    return state === 'delivered' || state === 'preprint_posted';
  }),
  incomplete: Ember.computed('state', function() {
    let state = this.get('state');
    return state === 'pending' || state === 'in_progress';
  }),
  published: Ember.computed.equal('state', 'preprint_posted'),

  preprintDoiAssigned: Ember.computed('destination', 'paper.aarxDoi', function(){
    let ppDoi = this.get('paper.aarxDoi');
    let preprintDoiExists = ppDoi !== undefined && ppDoi !== null && ppDoi.length > 0;
    return this.get('destination') === 'preprint' && preprintDoiExists;
  }),

  exportDoi: Ember.computed('paper.aarxDoi', 'paper.doi', 'destination', function() {
    if (this.get('destination') === 'preprint') {
      return this.get('paper.aarxDoi');
    } else {
      return this.get('paper.doi');
    }
  }),

  humanReadableState: Ember.computed('state', function() {
    return {
      pending: 'is pending',
      in_progress: 'is in progress',
      failed: 'has failed',
      delivered: 'succeeded',
      preprint_posted: 'succeeded'
    }[this.get('state')];
  })
});
