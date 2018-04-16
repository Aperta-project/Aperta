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
  attachments: DS.hasMany('decision-attachment', { async: false }),
  authorResponse: DS.attr('string'),
  // Draft is always != competed, so we only serialize one.
  completed: Ember.computed.not('draft'),
  createdAt: DS.attr('date'),
  draft: DS.attr('boolean'),
  initial: DS.attr('boolean'),
  invitations: DS.hasMany('invitation', { async: true }),
  latestRegistered: DS.attr('boolean'),
  letter: DS.attr('string'),
  majorVersion: DS.attr('number'),
  minorVersion: DS.attr('number'),
  nestedQuestionAnswers: DS.hasMany('nested-question-answer', { async: false }),
  paper: DS.belongsTo('paper', { async: false }),
  registeredAt: DS.attr('date'),
  rescindable: DS.attr('boolean'),
  rescinded: DS.attr('boolean'),
  reviewerReports: DS.hasMany('reviewerReport', { async: false }),
  verdict: DS.attr('string'),

  terminal: Ember.computed.match('verdict', /^(accept|reject)$/),

  restless: Ember.inject.service('restless'),

  rescind() {
    return this.get('restless')
      .put(`/api/decisions/${this.get('id')}/rescind`)
      .then((data) => {
        this.get('store').pushPayload(data);
        return this;
      });
  },

  register(task) {
    const registerPath = `/api/decisions/${this.get('id')}/register`;
    return this.save().then(() => {
      return this.get('restless').put(registerPath, {task_id: task.get('id')});
    }).then((data) => {
      this.get('store').pushPayload(data);
      return this;
    });
  },

  revisionNumber: Ember.computed('minorVersion', 'majorVersion', function() {
    return `${this.get('majorVersion')}.${this.get('minorVersion')}`;
  })
});
