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
  latestVersionedText: Ember.computed.alias('task.paper.latestVersionedText'),
  latestVersionSimilarityChecks: Ember.computed.alias('latestVersionedText.similarityChecks'),
  latestVersionSuccessfulChecks: Ember.computed.filterBy('latestVersionSimilarityChecks', 'state', 'report_complete'),
  latestVersionHasSuccessfulChecks: Ember.computed.notEmpty('latestVersionSuccessfulChecks.[]'),
  latestVersionFailedChecks: Ember.computed.filterBy('latestVersionSimilarityChecks', 'state', 'failed'),

  actions: {
    confirmGenerateReport() {
      this.set('confirmVisible', true);
    },
    cancel() {
      this.set('confirmVisible', false);
    },
    generateReport() {
      this.set('confirmVisible', false);
      this.get('task.paper.versionedTexts').then(() => {
        const similarityCheck = this.get('store').createRecord('similarity-check', {
          paper: this.get('task.paper'),
          versionedText: this.get('latestVersionedText')
        });
        similarityCheck.save();
      });
    }
  }
});
