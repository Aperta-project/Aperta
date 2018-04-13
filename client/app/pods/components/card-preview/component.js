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
import ENV from 'tahi/config/environment';

const { getOwner } = Ember;

export default Ember.Component.extend({
  can: Ember.inject.service('can'),
  classNames: ['task-disclosure-heading', 'card'],
  classNameBindings: ['task.completed:card--completed', 'classComponentName', 'notViewable:disabled'],

  classComponentName: Ember.computed.readOnly('task.componentName'),

  _propertiesCheck: Ember.on('init', function() {
    Ember.assert('You must pass a task property to the CardPreviewComponent', this.hasOwnProperty('task'));
  }),

  task: null,
  taskTemplate: false,
  canRemoveCard: false,
  version1: null,  // Will be a string like "1.2"
  version2: null,  // Will be a string like "1.2"
  reviewState: Ember.computed.alias('task.displayStatus'),

  // This is hack but the way we are creating a link but
  // not actually navigating to the link is non-ember-ish
  getRouter() {
    return getOwner(this).lookup('router:main');
  },

  href: Ember.computed('task.id', function() {
    // Getting access to the router from tests is impossible, sorry
    if(ENV.environment === 'test' || Ember.testing) { return '#'; }

    const paper = this.get('task.paper');
    if(Ember.isEmpty(paper)) { return '#'; }

    const router = this.getRouter();
    const args = ['paper.task', paper, this.get('task')];
    return router.generate.apply(router, args);
  }),

  unreadCommentsCount: Ember.computed('task.commentLooks.[]', function() {
    // NOTE: this fn is also used for 'task-templates', who do
    // not have comment-looks
    return (this.get('task.commentLooks') || []).length;
  }),

  versioned: Ember.computed.notEmpty('version1'),

  hasDiff: Ember.computed(
    'version1',
    'version2',
    'task.paper.snapshots.[]',
    function() {
      if (this.get('version1') && this.get('version2')) {
        let paper =  this.get('task.paper');
        let task = this.get('task');
        let snap1 = paper.snapshotForTaskAndVersion(task, this.get('version1'));
        let snap2 = paper.snapshotForTaskAndVersion(task, this.get('version2'));
        if (typeof(snap1) !== 'undefined') {
          return snap1.hasDiff(snap2);
        } else if (typeof(snap2) !== 'undefined') {
          return snap2.hasDiff(snap1);
        }
      }
      return false;
    }),

  notReviewerReportTask: Ember.computed('task', function() {
    let taskType = this.get('task.type');
    return (taskType !== 'ReviewerReportTask') && (taskType !== 'FrontMatterReviewerReportTask');
  }),

  showDeleteButton: Ember.computed.and('canRemoveCard', 'notReviewerReportTask'),

  notViewable: Ember.computed.not('viewable'),
  viewable: Ember.computed.or('taskTemplate', 'task.viewable'),

  actions: {
    viewCard() {
      if (this.get('notViewable')) { return; }

      let action = this.get('action');
      if (action) { action(); }
    },

    promptDelete() {
      this.sendAction('showDeleteConfirm', this.get('task'));
    },

    openSettings() {
      this.get('showSettings')();
    }
  },

  settingsEnabled: Ember.computed('task.settingsEnabled', function() {
    return this.get('task.settingsEnabled');
  })
});
