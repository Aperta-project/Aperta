import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const {
  Component,
  computed,
  computed: { alias, and, not, or },
  inject: { service },
  isEmpty
} = Ember;

export default Component.extend(ValidationErrorsMixin, {
  can: service(),
  classNames: ['task'],
  classNameBindings: [
    'isNotEditable:read-only',
    'taskStateToggleable:user-can-make-editable'
  ],
  dataLoading: true,

  init() {
    this._super(...arguments);
    this.set('store', getOwner(this).lookup('store:main'));
    this.set('editAbility', this.get('can').build('edit', this.get('task')));
  },

  isMetadataTask: alias('task.isMetadataTask'),
  isSubmissionTask: alias('task.isSubmissionTask'),
  isOnlyEditableIfPaperEditable: alias('task.isOnlyEditableIfPaperEditable'),

  isEditableDueToPermissions: alias('editAbility.can'),
  isEditableDueToTaskState: not('task.completed'),

  isEditable: and(
    'isEditableDueToPermissions',
    'isEditableDueToTaskState'),
  isNotEditable: not('isEditable'),

  taskCompleted: alias('task.completed'),
  taskStateToggleable: alias('isEditableDueToPermissions'),

  save() {
    this.set('validationErrors.completed', '');
    if(this.validateData) { this.validateData(); }

    if(this.validationErrorsPresent()) {
      this.set('task.completed', false);
      this.set('validationErrors.completed', 'Please fix all errors');
      return;
    }

    return this.get('task').save().then(()=> {
      this.clearAllValidationErrors();
    }, (response) => {
      this.displayValidationErrorsFromResponse(response);
      this.set('task.completed', false);
    });
  },

  validateAll() {
    this.validateProperties();
    this.validateQuestions();
  },

  validateProperty(key) {
    this.validate(key, this.get(`task.${key}`));
  },

  validateProperties() {
    const validations = this.get('validations');
    if(isEmpty(validations)) { return; }

    _.keys(validations).forEach(key => {
      this.validateProperty(key);
    });
  },

  validateQuestion(key, value) {
    this.validate(key, value);
  },

  validateQuestions() {
    if(isEmpty(this.get('questionValidations'))) { return; }

    const nestedQuestionAnswers = this.get('task.nestedQuestions')
                                      .mapProperty('answers');

    // NOTE: nested-questions.answers is hasMany relationship
    // so we need to flatten
    const answers = _.flatten(nestedQuestionAnswers.map(function(arr) {
      return _.compact( arr.map(function(a) {
        return a;
      }) );
    }) );

    answers.forEach(answer => {
      const key = answer.get('nestedQuestion.ident');
      const value = answer.get('value');

      this.validate(key, value);
    });
  },

  actions: {
    save()  { return this.save(); },
    close() { this.attrs.close(); },

    validateQuestion(key, value) {
      this.validateQuestion(key, value);
    },

    toggleTaskCompletion() {
      this.toggleProperty('task.completed');
      this.save();
    }
  }
});
