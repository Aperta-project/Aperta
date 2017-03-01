import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import ObjectProxyWithErrors from 'tahi/models/object-proxy-with-validation-errors';
import MultiExpandableList from 'tahi/mixins/multi-expandable-list';

const {
  computed,
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
        let answer = author.answerForIdent(ident);
        if(!answer){
          console.error(`Tried to find an answer for question with ident, ${ident}, but none was found`);
        } else {
          return answer.get('value');
        }
      });
    }
  }]
};


export default TaskComponent.extend(MultiExpandableList, {
  classNames: ['authors-task'],
  validations: taskValidations,

  validateData() {
    this.validateAll();
    const objs = this.get('sortedAuthorsWithErrors');
    objs.invoke('validateAll');

    const taskErrors    = this.validationErrorsPresent();
    const authorsErrors = ObjectProxyWithErrors.errorsPresentInCollection(objs);

    if(taskErrors || authorsErrors) {
      this.set('validationErrors.completed', 'Please fix all errors');
    }
  },

  sortedAuthorsWithErrors: computed('task.paper.allAuthors.[]',
    function() {
      if (!this.get('task.paper.allAuthors')) {
        return;
      }
      return this.get('task.paper.allAuthors').map( (a) => {
        return ObjectProxyWithErrors.create({
          object: a,
          skipValidations: () => { return this.get('skipValidations'); },
          validations: a.validations
        });
      });
    }
  ),

  shiftAuthorPositions(author, newPosition) {
    author.set('position', newPosition);
    author.save();
  },

  createNewAuthor(modelName, cardName) {
    let maxPosition = _.max(this.get('sortedAuthorsWithErrors').mapBy('object.position'));
    let newPosition = maxPosition > 0 ? maxPosition + 1 : 1;
    const newAuthor = this.get('store').createRecord(modelName, {
      paper: this.get('task.paper'),
      position: newPosition,
      card: this.get('store').peekAll('card').findBy('name', cardName)
    });

    this.set('author', newAuthor);

    this.set('authorProxy', ObjectProxyWithErrors.create({
      object: newAuthor,
      validations: newAuthor.validations
    }));

    newAuthor.save().then((author) => { this.setExpanded(author); });
  },

  actions: {
    createGroupAuthor() {
      this.createNewAuthor('group-author', 'GroupAuthor');
    },

    createAuthor() {
      this.createNewAuthor('author', 'Author');
    },

    saveNewAuthorSuccess() {
      this.notifyPropertyChange('sentinal');
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
