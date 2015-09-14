import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

const { computed } = Ember;

export default TaskController.extend({
  publicationDate: function() {
    return this.get("model.body.publicationDate");
  }.property(),

  volumeNumber: function() {
    return this.get("model.body.volumeNumber");
  }.property(),

  issueNumber: function() {
    return this.get("model.body.issueNumber");
  }.property(),

  publicationNotes: function() {
    return this.get("model.body.publicationNotes");
  }.property(),

  setPublicationDate: function() {
    this.callDebounce('publicationDate')
  }.observes('publicationDate'),

  setVolumeNumber: function() {
    this.callDebounce('volumeNumber')
  }.observes('volumeNumber'),

  setIssueNumber: function() {
    this.callDebounce('issueNumber')
  }.observes('issueNumber'),

  setPublicationNotes: function() {
    this.callDebounce('publicationNotes')
  }.observes('publicationNotes'),

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
