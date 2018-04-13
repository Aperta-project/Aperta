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
import formatDate from 'tahi/lib/aperta-moment';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),
  attachments: DS.hasMany('correspondence-attachment', { async: false }),
  date: DS.attr('string'),
  subject: DS.attr('string'),
  recipients: DS.attr('string'),
  recipient: DS.attr('string'),
  sender: DS.attr('string'),
  body: DS.attr('string'),
  external: DS.attr('boolean', { defaultValue: false }),
  description: DS.attr('string'),
  cc: DS.attr('string'),
  bcc: DS.attr('string'),
  sentAt: DS.attr('date'),
  manuscriptVersion: DS.attr('string'),
  manuscriptStatus: DS.attr('string'),
  activities: DS.attr(),
  status: DS.attr('string'),
  additionalContext: DS.attr(),

  isDeleted: Ember.computed('status', 'external', function() {
    return this.get('status') === 'deleted';
  }),
  isActive: Ember.computed.not('isDeleted'),

  utcSentAt: Ember.computed('sentAt', 'status', function() {
    if (this.get('status') === 'deleted') return '';

    let sentAt = this.get('sentAt');
    let time = Ember.isBlank(sentAt) ? moment.utc() : moment.utc(sentAt);
    return formatDate(time, 'long-date-time-1');
  }),

  manuscriptVersionStatus: Ember.computed('manuscriptVersion','manuscriptStatus', function() {
    let version_status = this.get('manuscriptVersion') + ' ' + this.get('manuscriptStatus');
    version_status = version_status.replace('null','').trim();

    if (version_status === 'null') {
      return 'Unavailable';
    }
    else {
      return version_status;
    }
  }),

  hasAnyAttachment: Ember.computed('attachments', function() {
    return (this.get('attachments').length !== 0);
  }),

  hasActivities: Ember.computed.notEmpty('activities'),

  activityNames: {
    'correspondence.created': 'Added',
    'correspondence.edited': 'Edited',
    'correspondence.deleted': 'Deleted'
  },

  activityMessages: Ember.computed.map('activities', function(activity) {
    return `${this.get('activityNames')[activity.key]} by ${activity.full_name} on ${formatDate(activity.created_at, 'long-date-time-2')}`;
  }),

  lastActivityMessage: Ember.computed('activityMessages', function(){
    return this.get('activityMessages.firstObject');
  })
});
