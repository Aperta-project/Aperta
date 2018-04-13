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

import Answerable from 'tahi/mixins/answerable';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/pods/nested-question-owner/model';
import Ember from 'ember';

export default NestedQuestionOwner.extend(Answerable, {
  decision: DS.belongsTo('decision'),
  task: DS.belongsTo('task'),
  user: DS.belongsTo('user'),
  status: DS.attr('string'),
  statusDatetime: DS.attr('date'),
  revision: DS.attr('string'),
  createdAt: DS.attr('date'),
  submitted: DS.attr('boolean'),
  dueDatetime: DS.belongsTo('due_datetime', { async: false }),

  originallyDueAt: DS.attr('date'),
  needsSubmission: Ember.computed('status', 'submitted', function() {
    var status = this.get('status');
    return !this.get('submitted') && status === 'pending';
  }),
  scheduledEvents: DS.hasMany('scheduled-event'),
  adminEdits: DS.hasMany('admin-edit'),
  activeAdminEdit: DS.attr('boolean'),
  inactiveAdminEdits: Ember.computed('adminEdits.@each.active', function() {
    if(this.get('adminEdits.length')) {
      return this.get('adminEdits').filterBy('active', false).sortBy('updatedAt').reverse();
    }
  })
});
