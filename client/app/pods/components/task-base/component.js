import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const { computed, isEmpty } = Ember;
const { alias, not, or } = computed;

export default Ember.Component.extend(ValidationErrorsMixin, {
  can: Ember.inject.service('can'),
  classNames: ['task'],
  dataLoading: true,

  init() {
    this._super(...arguments);
    this.set('store', this.container.lookup('store:main'));
  },

  isMetadataTask: alias('task.isMetadataTask'),
  isSubmissionTask: alias('task.isSubmissionTask'),

  isSubmissionTaskEditable: computed('isEditable', function(){
    console.warn("isSubmissionTaskEditable called which is deprecated. Please use isEditable. Called on ", this._debugContainerKey, this);
    return this.get('isEditable');
  }),

  isSubmissionTaskNotEditable: computed('isNotEditable', function(){
    console.warn("isSubmissionTaskNotEditable called which is deprecated. Please use isNotEditable. Called on ", this._debugContainerKey, this);
    return this.get('isNotEditable');
  }),

  fieldsDisabled: or('isNotEditable', 'task.completed'),
  isEditable: or('isUserEditable', 'currentUser.siteAdmin'),
  isNotEditable: not('isEditable'),
  isUserEditable: computed('userHasPermission', 'task.paper.editable', 'isSubmissionTask', function(){
    return this.get('userHasPermission') && (
      this.get('task.paper.editable') || !this.get('isSubmissionTask')
    );
  }),
  userHasPermission: Ember.observer('task', function(){
    this.get('can').can('view', this.get('task')).then( (value)=> {
      this.set('userHasPermission', value);
    });
    return false;
  }),

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
    this.validate(key, value, this.get('validations.' + key));
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
      const validations = allValidations[key];
      if(isEmpty(validations)) { return; }

      const value = answer.get('value');
      this.validate(key, value, validations);
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
