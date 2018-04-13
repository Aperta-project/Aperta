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

import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  init: function() {
    this._super(...arguments);
    this.get('task.paper.similarityChecks');
  },
  flash: Ember.inject.service(),
  restless: Ember.inject.service(),
  classNames: ['similarity-check-task'],
  sortProps: ['id:desc'],
  latestVersionedText: Ember.computed.alias('task.paper.latestVersionedText'),
  latestVersionSimilarityChecks: Ember.computed.alias('latestVersionedText.similarityChecks.[]'),
  latestVersionHasChecks: Ember.computed.notEmpty('latestVersionedText.similarityChecks.[]'),
  latestVersionSuccessfulChecks: Ember.computed.filterBy('latestVersionSimilarityChecks', 'state', 'report_complete'),
  latestVersionHasSuccessfulChecks: Ember.computed.notEmpty('latestVersionSuccessfulChecks.[]'),
  latestVersionFailedChecks: Ember.computed.filterBy('latestVersionSimilarityChecks', 'state', 'failed'),
  latestVersionPrimaryFailedChecks: Ember.computed.filterBy('latestVersionFailedChecks', 'dismissed', false),
  sortedChecks: Ember.computed.sort('latestVersionSimilarityChecks', 'sortProps'),
  automatedReportsDisabled: Ember.computed.reads('task.paper.manuallySimilarityChecked'),
  automatedReportsOff: Ember.computed.equal('task.currentSettingValue', 'off'),
  showAutomatedReportMsg: Ember.computed.or('automatedReportsOff', 'automatedReportsDisabled'),

  confirmVisible: false,

  versionedTextDescriptor: Ember.computed('task.currentSettingValue', function() {
    const setting = this.get('task.currentSettingValue');
    let settingNames = {
      at_first_full_submission: 'first full submission',
      after_major_revise_decision: 'major revision',
      after_minor_revise_decision: 'minor revision',
      after_any_first_revise_decision: 'any first revision'
    };

    return settingNames[setting];
  }),

  disableReports: Ember.computed('latestVersionHasChecks', 'automatedReportsDisabled', function() {
    //dont ever disable disable manual generation button if auto reports are disabled.
    return this.get('latestVersionHasChecks') &&  !this.get('automatedReportsDisabled');
  }),

  actions: {
    confirmGenerateReport() {
      this.set('confirmVisible', true);
    },
    cancel() {
      this.set('confirmVisible', false);
    },
    generateReport() {
      this.set('confirmVisible', false);
      const paper = this.get('task.paper');
      paper.get('versionedTexts').then(() => {
        const similarityCheck = this.get('store').createRecord('similarity-check', {
          paper: paper,
          versionedText: this.get('latestVersionedText')
        });
        similarityCheck.save();
      }).then(() => {
        // force paper to recalculate if auto reports are disabled
        paper.reload();
      });
    },
    dismissMessage(message) {
      message.set('dismissed', true);
      message.save();
    }
  }
});
