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
import { formatDate, moment } from 'tahi/lib/aperta-moment';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  restless: Ember.inject.service('restless'),

  classNames: ['report-status'],
  readOnly: false,
  editingClass: Ember.computed('report.activeAdminEdit', function() {
    return this.get('report.activeAdminEdit') ? 'editing' : '';
  }),

  shortStatus: Ember.computed.reads('short'),

  dueDatetime: Ember.computed.alias('report.dueDatetime'),

  statusSubMessage: Ember.computed('report.status','report.revision','statusDate', 'report.originallyDueAt', 'report.dueDatetime.dueAt', function() {
    const status = this.get('report.status');
    var output = '';
    const verbs = {
      'pending': 'accepted',
      'invitation_invited': 'sent on',
      'invitation_accepted': 'accepted',
      'invitation_declined': 'declined',
      'invitation_rescinded': 'rescinded'
    };
    if (['invitation_pending', 'not_invited'].includes(status)) {
      output = 'This candidate has not been invited to ' + this.get('report.revision');
    } else {
      output = `Invitation ${verbs[status]} ${this.get('statusDate')}`;
    }

    const dueDate = this.get('report.dueDatetime.dueAt');
    const originalDueDate = this.get('report.originallyDueAt');
    const format = 'long-month-day-1';
    const formattedDueDate = formatDate(dueDate, format);
    const formattedOriginalDueDate = formatDate(originalDueDate, format);
    if (dueDate && formattedDueDate !== formattedOriginalDueDate) {
      output += `; original due date was ${formattedOriginalDueDate}.`;
    }
    return output;
  }),

  statusMessage: Ember.computed('report.status','report.revision','reviewDueAt', 'reviewDueMessage', function() {
    const status = this.get('report.status');
    var output = '';

    if (!['invitation_pending', 'not_invited'].includes(status)) {
      output = 'review of ' + this.get('report.revision') + this.get('reviewDueMessage');
    }
    return output;
  }),

  statusDate: Ember.computed('report.statusDatetime', function(){
    const date = this.get('report.statusDatetime');
    const format = 'long-date-1';
    return formatDate(date, format);
  }),

  reviewDueMessage: Ember.computed('dueDatetime.dueAt', function(){
    const date = this.get('dueDatetime.dueAt');
    var output = '';
    if (date) {
      const format = 'long-date-short-time-zone';
      const zone = moment.tz.guess();
      output = ' due ' + formatDate(moment(date).tz(zone), format);
    }
    return output;
  }),

  reviewerStatus: Ember.computed('report.status', function() {
    const status = this.get('report.status');
    const statuses = {
      'pending': 'Pending',
      'not_invited': 'Not yet invited',
      'completed': 'Completed',
      'invitation_pending': 'Not yet invited',
      'invitation_invited': 'Invited',
      'invitation_accepted': 'Pending',
      'invitation_declined': 'Declined',
      'invitation_rescinded': 'Rescinded'
    };
    return statuses[status];
  }),

  actions: {
    changeDueDate(newDate) {
      var hours = this.get('dueDatetime.dueAt').getHours();
      newDate.setHours(hours);
      this.set('dueDatetime.dueAt', newDate);
      this.get('dueDatetime').save();
    },

    editReport() {
      let report = this.get('report');
      report.set('editWaiting', true);
      this.get('store').createRecord('admin-edit', {reviewerReport: report}).save().then(function() {
        report.set('editWaiting', false);
        report.set('activeAdminEdit', true);
      });
    }
  }
});
