import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import ObjectProxyWithErrors from 'tahi/models/object-proxy-with-validation-errors';
import validations from 'tahi/authors-task-validations';
import { taskValidations } from 'tahi/authors-task-validations';

const {
  computed,
  computed: { sort },
  on
} = Ember;

export default TaskComponent.extend({
  validations: taskValidations,
  newAuthorFormVisible: false,
  newGroupAuthorFormVisible: false,

  validateData() {
    this.validateAll();
    const objs = this.get('sortedAuthorsWithErrors');
    objs.invoke('validateAll');

    const taskErrors    = this.validationErrorsPresent();
    const authorsErrors = ObjectProxyWithErrors.errorsPresentInCollection(objs);
    let newAuthorErrors = false;

    if(this.get('newAuthorFormVisible')) {
      const newAuthor= this.get('newAuthor');
      newAuthor.validateAll();

      if(newAuthor.validationErrorsPresent()) {
        newAuthorErrors = true;
      }
    }

    if(taskErrors || authorsErrors || newAuthorErrors) {
      this.set('validationErrors.completed', 'Please fix all errors');
    }
  },

  authors: computed('task.authors.@each.paper', function() {
    return this.get('task.authors').filterBy('paper', this.get('paper'));
  }),

  authorSort: ['position:asc'],
  sortedAuthors: sort('task.authors', 'authorSort'),
  sortedAuthorsWithErrors: computed('sortedAuthors.[]', function() {
    return this.get('sortedAuthors').map(function(a) {
      return ObjectProxyWithErrors.create({
        object: a,
        validations: validations
      });
    });
  }),

  nestedQuestionsForNewAuthor: Ember.A(),
  newAuthorQuestions: on('init', function(){
    const q = { type: 'Author' };
    this.store.findQuery('nested-question', q).then((nestedQuestions)=> {
      this.set('nestedQuestionsForNewAuthor', nestedQuestions);
    });
  }),

  newAuthor: null,

  clearNewAuthorAnswers(){
    this.get('nestedQuestionsForNewAuthor').forEach( (nestedQuestion) => {
      nestedQuestion.clearAnswerForOwner(this.get('newAuthor.object'));
    });
  },

  shiftAuthorPositions(author, newPosition) {
    author.set('position', newPosition).save();
  },

  actions: {
    toggleAuthorForm() {
      const newAuthor = this.store.createRecord('author', {
        paper: this.get('task.paper'),
        position: 0,
        nestedQuestions: this.get('nestedQuestionsForNewAuthor')
      });

      this.set('newAuthor', ObjectProxyWithErrors.create({
        object: newAuthor,
        validations: validations
      }));

      this.clearNewAuthorAnswers();
      this.toggleProperty('newAuthorFormVisible');
    },

    toggleGroupAuthorForm() {
      this.toggleProperty('newGroupAuthorFormVisible');
    },

    changeAuthorPosition(author, newPosition) {
      this.shiftAuthorPositions(author, newPosition);
    },

    saveNewAuthor() {
      const proxy = this.get('newAuthor');
      const model = proxy.get('object');

      // set this here, not when initially built so it doesn't show up in
      // the list of existing authors as the user fills out the form
      model.set('task', this.get('task'));

      model.save().then( (savedAuthor) => {
        model.get('nestedQuestionAnswers').toArray().forEach(function(answer){
          const value = answer.get('value');
          if(value || value === false){
            answer.set('owner', savedAuthor);
            answer.save();
          }
        });
        this.toggleProperty('newAuthorFormVisible');
      });
    },

    saveAuthor(author) {
      author.save();
    },

    removeAuthor(author) {
      author.destroyRecord();
    },

    validateField(model, key, value) {
      model.validate(key, value);
    }
  }
});
