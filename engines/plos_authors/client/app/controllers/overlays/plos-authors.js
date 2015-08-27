import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

let computed = Ember.computed;

export default TaskController.extend({
  title: 'Authors',
  newAuthorFormVisible: false,

  authors: computed('model.plosAuthors.@each.paper', function() {
    return this.get('model.plosAuthors').filterBy('paper', this.get('paper'));
  }),

  authorSort: ['position:asc'],
  sortedAuthors: computed.sort('model.plosAuthors', 'authorSort'),
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
        plosAuthorsTask: this.get('model'),
        position: 0
      });

      this.store.createRecord('plosAuthor', newAuthorHash).save();
      this.toggleProperty('newAuthorFormVisible');
    },

    saveAuthor(plosAuthor) {
      this.clearAllValidationErrorsForModel(plosAuthor);
      plosAuthor.save();
    },

    removeAuthor(plosAuthor) {
      plosAuthor.destroyRecord();
    }
  }
});
