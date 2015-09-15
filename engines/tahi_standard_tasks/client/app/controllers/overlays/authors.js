import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

let computed = Ember.computed;

export default TaskController.extend({
  title: 'Authors',
  newAuthorFormVisible: false,

  authors: computed('model.authors.@each.paper', function() {
    return this.get('model.authors').filterBy('paper', this.get('paper'));
  }),

  authorSort: ['position:asc'],
  sortedAuthors: computed.sort('model.authors', 'authorSort'),
  fetchAffiliations: Ember.on('didSetupController', function() {
    Ember.$.getJSON('/api/affiliations', (data)=> {
      this.set('model.institutions', data.institutions);
    });
  }),

  sortedAuthorsWithErrors: computed(
    'sortedAuthors.@each', 'validationErrors', function() {
    return this.createModelProxyObjectWithErrors(this.get('sortedAuthors'));
  }),

  shiftAuthorPositions(author, newPosition) {
    author.set('position', newPosition).save();
  },

  actions: {
    toggleAuthorForm() {
      this.toggleProperty('newAuthorFormVisible');
      return false;
    },

    changeAuthorPosition(author, newPosition) {
      this.shiftAuthorPositions(author, newPosition);
    },

    saveNewAuthor(newAuthorHash) {
      Ember.merge(newAuthorHash, {
        paper: this.get('model.paper'),
        authorsTask: this.get('model'),
        position: 0
      });

      this.store.createRecord('author', newAuthorHash).save();
      this.toggleProperty('newAuthorFormVisible');
    },

    saveAuthor(author) {
      this.clearAllValidationErrorsForModel(author);
      author.save();
    },

    removeAuthor(author) {
      author.destroyRecord();
    }
  }
});
