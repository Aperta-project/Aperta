import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const { computed } = Ember;
const { alias } = computed;

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNames: ['task'],
  dataLoading: true,

  init() {
    this._super(...arguments);
    this.set('store', this.container.lookup('store:main'));
  },

  isMetadataTask: alias('task.isMetadataTask'),
  isSubmissionTask: alias('task.isSubmissionTask'),
  isSubmissionTaskEditable: alias('task.paper.editable'),
  isSubmissionTaskNotEditable: computed.not('task.paper.editable'),
  isEditable: computed.or('isUserEditable', 'currentUser.siteAdmin'),
  fieldsDisabled: computed.or('isSubmissionTaskNotEditable', 'task.completed'),
  isUserEditable: computed('task.paper.editable', 'isSubmissionTask',
    function() {
      return this.get('task.paper.editable') || !this.get('isSubmissionTask');
    }
  ),

  save() {
    this.validateQuestions();
    this.set('validationErrors.completed', '');

    if(this.validationErrorsPresent()) {
      this.set('task.completed', false);
      return;
    }

    return this.get('task').save().then(()=> {
      this.clearAllValidationErrors();
    }, (response) => {
      this.displayValidationErrorsFromResponse(response);
      this.set('task.completed', false);
    });
  },

  answers: computed('task.nestedQuestions.[]', function() {
    return this.get('task.nestedQuestions').map(q => {
      return q.answerForOwner(
        this.get('task'), this.get('task.paper.latestDecision')
      );
    });
  }),

  isValid: computed('answers.@each.value', function() {
    this.validateQuestions();
    return !this.validationErrorsPresent();
  }),

  validateQuestions() {
    this.get('answers').forEach(answer => {
      const key = answer.get('nestedQuestion.ident');
      const validations = this.get('validations')[key];
      if(Ember.isEmpty(validations)) { return; }

      // answers is a hasMany
      const value = answer.get('value');
      this.validate(key, value, validations);
    });
  },

  actions: {
    save()  { return this.save(); },
    close() { this.attrs.close(); },

    validateQuestion(key, value) {
      this.validate(key, value, this.get('validations.' + key));
    },

    toggleTaskCompletion() {
      this.set('task.completed', !this.get('task.completed'));
      this.save();
    }
  }
});
