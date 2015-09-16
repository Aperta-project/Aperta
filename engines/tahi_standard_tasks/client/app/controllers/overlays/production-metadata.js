import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

export default TaskController.extend({
  publicationDate: Ember.computed("model.body.publicationDate", function () {
    return this.get('model.body.publicationDate');
  }),

  volumeNumber: Ember.computed("model.body.volumeNumber", function () {
    return this.get('model.body.volumeNumber');
  }),

  issueNumber: Ember.computed("model.body.issueNumber", function () {
    return this.get('model.body.issueNumber');
  }),

  productionNotes: Ember.computed("model.body.productionNotes", function () {
    return this.get('model.body.productionNotes');
  }),

  setPublicationDate: Ember.observer('publicationDate', function() {
    this.callDebounce('publicationDate');
  }),

  setVolumeNumber: Ember.observer('volumeNumber', function() {
    this.callDebounce('volumeNumber');
  }),

  setIssueNumber: Ember.observer('issueNumber', function() {
    this.callDebounce('issueNumber');
  }),

  setPublicationNotes: Ember.observer('productionNotes', function() {
    this.callDebounce('productionNotes');
  }),

  callDebounce: function(key) {
    return Ember.run.debounce(this, this.setAndSave, [key], 1000);
  },

  setAndSave(key){
    this.ensureBody();
    this.set(`model.body.${key}`, this.get(`${key}`));
    this.get('model').save();
  },

  ensureBody: function() {
    if (this.get('model.body').length === 0 && typeof(this.get('model.body') !== Array)) {
      this.set('model.body', {});
    }
  }
});
