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
import CardThumbnailObserver from 'tahi/mixins/models/card-thumbnail-observer';
import Answerable from 'tahi/mixins/answerable';
import NestedQuestionOwner from 'tahi/pods/nested-question-owner/model';
import Snapshottable from 'tahi/mixins/snapshottable';
import { timeout, task as concurrencyTask } from 'ember-concurrency';

export default NestedQuestionOwner.extend(Answerable, CardThumbnailObserver, Snapshottable, {
  exportDeliveries: DS.hasMany('export-delivery', {
    inverse: 'task'
  }),
  attachments: DS.hasMany('adhoc-attachment', {
    inverse: 'task'
  }),
  cardThumbnail: DS.belongsTo('card-thumbnail', {
    inverse: 'task',
    async: false
  }),
  cardVersion: DS.belongsTo('card-version'),
  commentLooks: DS.hasMany('comment-look', {
    inverse: 'task',
    async: false
  }),
  comments: DS.hasMany('comment', { async: true }),
  paper: DS.belongsTo('paper', {
    inverse: 'tasks',
    async: false
  }),
  participations: DS.hasMany('participation', { async: true }),
  phase: DS.belongsTo('phase', {
    inverse: 'tasks'
  }),
  repetitions: DS.hasMany('repetition'),
  snapshots: DS.hasMany('snapshot', {
    inverse: 'source'
  }),
  invitations: DS.hasMany('invitation', {
    async: true
  }),

  body: DS.attr(),
  completed: DS.attr('boolean'),
  completedProxy: DS.attr('boolean'),
  decisions: Ember.computed.alias('paper.decisions'),
  isMetadataTask: DS.attr('boolean'),
  isSnapshotTask: DS.attr('boolean'),
  isSubmissionTask: DS.attr('boolean'),
  isWorkflowOnlyTask: DS.attr('boolean'),
  isOnlyEditableIfPaperEditable: Ember.computed.or(
    'isMetadataTask',
    'isSubmissionTask'
  ),
  permissionState: Ember.computed.alias('paper.permissionState'),
  position: DS.attr('number'),
  qualifiedType: DS.attr('string'),
  title: DS.attr('string'),
  type: DS.attr('string'),
  viewable: DS.attr('boolean'),
  notReady: DS.attr('boolean'),
  displayStatus: DS.attr('string'),
  assignedToMe: DS.attr(),
  debouncePeriod: 200, // ms
  assignedUser: DS.belongsTo('user'),
  taskNotReady: Ember.computed.equal('notReady', true),

  componentName: Ember.computed('type', function() {
    return Ember.String.dasherize(this.get('type'));
  }),

  paperTitle: Ember.computed('paper', function() {
    return this.get('paper.displayTitle');
  }),

  getSnapshotForVersion: function(fullVersion) {
    return this.get('snapshots').findBy('fullVersion', fullVersion);
  },

  responseToQuestion(key) {
    var questionResponse = (this.answerForQuestion(key) || Ember.ObjectProxy.create());
    return questionResponse.get('value');
  },

  isSidebarTask: Ember.computed('assignedToMe', 'isSubmissionTask', 'isWorkflowOnlyTask', function(){
    if (this.get('isWorkflowOnlyTask')) {
      return false;
    }

    if (this.get('componentName') === 'custom-card-task') {
      // custom card tasks will display on sidebar by default
      return true;
    } else {
      // non-custom card (legacy) tasks will display on sidebar conditionally
      return this.get('assignedToMe') || this.get('isSubmissionTask');
    }
  }),

  debouncedSave: concurrencyTask(function * () {
    yield timeout(this.get('debouncePeriod'));
    return yield this.save();
  }).restartable()
});
