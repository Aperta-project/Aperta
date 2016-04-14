import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import ObjectProxyWithErrors from 'tahi/models/object-proxy-with-validation-errors';

const {
  computed
} = Ember;

const acknowledgementIdents = [
  'authors--persons_agreed_to_be_named',
  'authors--authors_confirm_icmje_criteria',
  'authors--authors_agree_to_submission',
];

const taskValidations = {
  'acknowledgements': [{
    type: 'equality',
    message: 'Please acknowledge the statements below',
    validation() {
      const author = this.get('task');

      return _.every(acknowledgementIdents, (ident) => {
        return author.answerForQuestion(ident).get('value');
      });
    }
  }]
};

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

  sortedAuthorsWithErrors: computed('task.paper.allAuthors.[]',
    function() {
      if (!this.get('task.paper.allAuthors')) {
        return;
      }
      return this.get('task.paper.allAuthors').map(function(a) {
        return ObjectProxyWithErrors.create({
          object: a,
          validations: a.validations
        });
      });
    }
  ),

  sortedSavedAuthorsWithErrors: computed.filterBy(
    'sortedAuthorsWithErrors',
    'object.isNew', false),

  shiftAuthorPositions(author, newPosition) {
    author.set('position', newPosition).save();
  },

  actions: {
    toggleGroupAuthorForm() {
      this.toggleProperty('newGroupAuthorFormVisible');
    },

    toggleAuthorForm() {
      this.toggleProperty('newAuthorFormVisible');
    },

    saveNewAuthorSuccess() {
      this.set('newAuthorFormVisible', false);
    },

    saveNewGroupAuthorSuccess() {
      this.set('newGroupAuthorFormVisible', false);
    },

    changeAuthorPosition(author, newPosition) {
      this.shiftAuthorPositions(author, newPosition);
    },

    removeAuthor(author) {
      author.destroyRecord();
    },

    validateField(model, key, value) {
      model.validate(key, value);
    }
  }
});
