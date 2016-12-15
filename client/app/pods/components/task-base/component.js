import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import { task as concurrencyTask } from 'ember-concurrency';

const {
  Component,
  computed: { alias, and, not },
  inject: { service },
  isEmpty
} = Ember;

export default Component.extend(ValidationErrorsMixin, {
  can: service(),
  store: service(),

  classNames: ['task'],
  classNameBindings: [
    'isNotEditable:read-only',
    'taskStateToggleable:user-can-make-editable'
  ],
  dataLoading: true,

  completedErrorText: 'Please fix all errors',

  init() {
    this._super(...arguments);
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

  taskStateToggleable: alias('isEditableDueToPermissions'),

  saveTask: concurrencyTask(function * () {
    try {
      yield this.get('task').save();
      this.clearAllValidationErrors();
    } catch (response) {
      this.displayValidationErrorsFromResponse(response);
      this.set('task.completed', false);
    }
  }),

  save() {
    this.set('validationErrors.completed', '');
    if(this.validateData) { this.validateData(); }

    if(this.validationErrorsPresent()) {
      this.set('task.completed', false);
      this.set('validationErrors.completed', this.get('completedErrorText'));
      return;
    }

    return this.get('saveTask').perform();
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
                                      .mapBy('answers');

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
      let isCompleted = this.toggleProperty('task.completed');

      // if task is now incomplete skip validations
      this.set('skipValidations', !isCompleted);
      this.save();
    }
  }
});
