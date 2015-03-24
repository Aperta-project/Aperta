import Ember from 'ember';
import TaskController from 'tahi/pods/task/controller';

export default TaskController.extend({
  newAuthorFormVisible: false,

  authors: (function() {
    return this.get('model.plosAuthors').filterBy('paper', this.get('paper'));
  }).property('model.plosAuthors.@each.paper'),

  authorSort: ['position:asc'],
  sortedAuthors: Ember.computed.sort('model.plosAuthors', 'authorSort'),
  fetchAffiliations: function() {
    let self = this;

    Ember.$.getJSON('/affiliations', function(data) {
      self.set('model.institutions', data.institutions);
    });
  }.on('didSetupController'),

  sortedAuthorsWithErrors: (function() {
    return this.createModelProxyObjectWithErrors(this.get('sortedAuthors'));
  }).property('sortedAuthors.@each', 'validationErrors'),

  shiftAuthorPositions: function(author, newPosition) {
    author.set('position', newPosition).save();
  },

  actions: {
    toggleAuthorForm: function() {
      this.toggleProperty('newAuthorFormVisible');
      return false;
    },

    saveNewAuthor: function(newAuthorHash) {
      Ember.merge(newAuthorHash, {
        paper: this.get('paper'),
        plosAuthorsTask: this.get('model'),
        position: 0
      });

      this.store.createRecord('plosAuthor', newAuthorHash).save();
      this.toggleProperty('newAuthorFormVisible');
    },

    saveAuthor: function(plosAuthor) {
      this.clearAllValidationErrorsForModel(plosAuthor);
      plosAuthor.save();
    },

    removeAuthor: function(plosAuthor) {
      plosAuthor.destroyRecord();
    }
  }
});
