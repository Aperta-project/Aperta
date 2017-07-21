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
  latestPaperVersion: Ember.computed.alias('task.paper.latestPaperVersion'),
  latestVersionSimilarityChecks: Ember.computed.alias('latestPaperVersion.similarityChecks.[]'),
  latestVersionSuccessfulChecks: Ember.computed.filterBy('latestVersionSimilarityChecks', 'state', 'report_complete'),
  latestVersionHasSuccessfulChecks: Ember.computed.notEmpty('latestVersionSuccessfulChecks.[]'),
  latestVersionFailedChecks: Ember.computed.filterBy('latestVersionSimilarityChecks', 'state', 'failed'),
  latestVersionPrimaryFailedChecks: Ember.computed.filterBy('latestVersionFailedChecks', 'dismissed', false),
  sortedChecks: Ember.computed.sort('latestVersionSimilarityChecks', 'sortProps'),

  actions: {
    confirmGenerateReport() {
      this.set('confirmVisible', true);
    },
    cancel() {
      this.set('confirmVisible', false);
    },
    generateReport() {
      this.set('confirmVisible', false);
      this.get('task.paper.paperVersions').then(() => {
        const similarityCheck = this.get('store').createRecord('similarity-check', {
          paper: this.get('task.paper'),
          paperVersion: this.get('latestPaperVersion')
        });
        similarityCheck.save();
      });
    },
    dismissMessage(message) {
      message.set('dismissed', true);
      message.save();
    }
  }
});
