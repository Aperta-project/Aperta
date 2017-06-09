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
  latestVersionSuccessfulChecks: Ember.computed.filterBy('latestVersionSimilarityChecks', 'state', 'report_complete'),
  latestVersionHasSuccessfulChecks: Ember.computed.notEmpty('latestVersionSuccessfulChecks.[]'),
  latestVersionFailedChecks: Ember.computed.filterBy('latestVersionSimilarityChecks', 'state', 'failed'),
  latestVersionPrimaryFailedChecks: Ember.computed.filterBy('latestVersionFailedChecks', 'dismissed', false),
  sortedChecks: Ember.computed.sort('latestVersionSimilarityChecks', 'sortProps'),
  latestVersionHasChecks: Ember.computed.notEmpty('latestVersionedText.similarityChecks.[]'),
  automatedReportsDisabled: Ember.computed.alias('task.paper.manuallySimilarityChecked'),

  versionedTextDescriptor: Ember.computed('latestVersionedText', function() {
    if (true) {
      return 'first full submission';
    } else if (false) {
      return 'first major revision';
    } else if (false) {
      return 'first minor revision';
    } else if (false) {
      return 'any first revision';
    }
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

      if (! paper.get('manuallySimilarityChecked')) {
        paper.set('manuallySimilarityChecked', true);
        paper.save();
      }

      paper.get('versionedTexts').then(() => {
        const similarityCheck = this.get('store').createRecord('similarity-check', {
          paper: paper,
          versionedText: this.get('latestVersionedText')
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
