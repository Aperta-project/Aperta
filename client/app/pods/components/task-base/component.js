import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const { computed, isEmpty } = Ember;
const { alias, not, or, and } = computed;

export default Ember.Component.extend(ValidationErrorsMixin, {
  can: Ember.inject.service('can'),
  classNames: ['task'],
  classNameBindings: [
    'isNotEditable:read-only',
    'taskStateToggleable:user-can-make-editable'
  ],
  dataLoading: true,

  init() {
    this._super(...arguments);
    this.set('store', this.container.lookup('store:main'));
    this.set('editAbility', this.get('can').build('edit', this.get('task')));
  },

  isMetadataTask: alias('task.isMetadataTask'),
  isSubmissionTask: alias('task.isSubmissionTask'),

  isEditableDueToPermissions: alias('editAbility.can'),
  isEditableDueToPaperState: computed(
    'task.paper.editable', 'isSubmissionTask',
    function() {
      return !this.get('isSubmissionTask') || this.get('task.paper.editable');
    }),
  isEditableDueToTaskState: not('task.completed'),

  isEditable: and(
    'isEditableDueToPaperState',
    'isEditableDueToPermissions',
    'isEditableDueToTaskState'),
  isNotEditable: not('isEditable'),

  taskStateToggleable: and('isEditableDueToPermissions', 'isEditableDueToPaperState'),

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

  validateQuestion(key, value) {
    this.validate(key, value);
  },

  validateQuestions() {
    const allValidations = this.get('validations');
    if(isEmpty(allValidations)) { return; }

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
      this.validate(key, value);
    },

    toggleTaskCompletion() {
      this.toggleProperty('task.completed');
      this.save();
    }
  }
});
