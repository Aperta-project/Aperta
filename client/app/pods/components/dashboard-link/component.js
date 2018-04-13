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
import formatDate from 'tahi/lib/aperta-moment';

export default Ember.Component.extend({
  attributeBindings: ['data-test-id'],
  'data-test-id': Ember.computed('model', function(){
    let paperId = this.get('model.id');
    return `dashboard-paper-${paperId}`;
  }),
  tagName: 'tr',
  unreadCommentsCount: Ember.computed.reads('model.commentLooks.length'),
  dueDate: Ember.computed.reads('model.reviewDueAt'),

  status: Ember.computed('model.publishingState', function() {
    if (this.get('model.publishingState') === 'unsubmitted') {
      return 'DRAFT';
    } else {
      return this.get('model.publishingState').replace(/_/g, ' ').toUpperCase();
    }
  }),

  roles: Ember.computed('model.roles', function() {
    if (this.get('model.roles').indexOf('My Paper') > -1) {
      return 'Author';
    } else {
      return this.get('model.roles');
    }
  }),

  reviewDueMessage: Ember.computed('model.roles', 'model.reviewDueAt', function() {
    if (this.get('model.roles').includes('Reviewer') && !Ember.isEmpty(this.get('model.reviewDueAt'))) {
      return 'Your review is due ' + formatDate(this.get('model.reviewDueAt'), 'long-month-day-2');
    } else {
      return '';
    }
  }),

  originallyDueMessage: Ember.computed('model.roles','model.reviewDueAt', function() {
    if (this.get('model.roles').includes('Reviewer') && !Ember.isEmpty(this.get('model.reviewOriginallyDueAt'))) {
      return 'Originally due ' + formatDate(this.get('model.reviewOriginallyDueAt'), 'long-month-day-2');
    } else {
      return '';
    }
  }),

  paperLinkId: Ember.computed(function(){
    return 'view-paper-' + this.get('model.id');
  }),
});
