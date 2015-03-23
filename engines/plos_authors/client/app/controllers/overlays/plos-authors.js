import Ember from 'ember';
import TaskController from 'tahi/pods/task/controller';

export default TaskController.extend({
  newAuthorFormVisible: false,
  allAuthors: [],

  _setAllAuthors: (function() {
    return this.set('allAuthors', this.store.all('plosAuthor'));
  }).on('init'),

  authors: (function() {
    return this.get('allAuthors').filterBy('paper', this.get('paper'));
  }).property('allAuthors.@each.paper'),

  authorSort: ['position:asc'],
  sortedAuthors: Ember.computed.sort('allAuthors', 'authorSort'),
  fetchAffiliations: function() {
    var self = this;

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
