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

  newAuthorQuestions: Ember.on('init', function(){
    this.store.findQuery('nested-question', { type: "Author" }).then( (nestedQuestions) => {
      this.set('nestedQuestionsForNewAuthor', nestedQuestions);
    });
  }),

  newAuthor: Ember.computed('newAuthorFormVisible', function(){
    return this.store.createRecord('author', {
        paper: this.get('model.paper'),
        authorsTask: this.get('model'),
        position: 0,
        nestedQuestions: this.get('nestedQuestionsForNewAuthor')
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
      let author = this.get("newAuthor");
      author.save().then( (savedAuthor) => {
        author.get('nestedQuestionAnswers').toArray().forEach(function(answer){
          let value = answer.get("value");
          if(value || value === false){
            answer.set("owner", savedAuthor);
            answer.save();
          }
        });
        this.toggleProperty('newAuthorFormVisible');
      });
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
