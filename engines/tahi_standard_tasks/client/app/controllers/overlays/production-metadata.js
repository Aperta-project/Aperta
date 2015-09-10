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
    this.send('ensureBody');
    this.send('setAndSave', 'publicationDate')
  }.observes('publicationDate'),

  setVolumeNumber: function() {
    this.send('ensureBody');
    this.send('setAndSave', 'volumeNumber')
  }.observes('volumeNumber'),

  setIssueNumber: function() {
    this.send('ensureBody');
    this.send('setAndSave', 'issueNumber')
  }.observes('issueNumber'),

  setPublicationNotes: function() {
    this.send('ensureBody');
    this.send('setAndSave', 'publicationNotes')
  }.observes('publicationNotes'),

  actions: {
    ensureBody(){
      if (this.get('model.body').length === 0 && typeof(this.get('model.body') != Array)) {
        this.set('model.body', {});
      }
    },

    setAndSave(key){
      this.set(`model.body.${key}`, this.get(`${key}`));
      this.get('model').save();
    }
  }

});
