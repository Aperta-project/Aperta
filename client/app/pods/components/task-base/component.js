import Ember from 'ember';
import Participants from 'tahi/mixins/controllers/controller-participants';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const { computed } = Ember;
const { alias } = computed;

export default Ember.Component.extend(Participants, ValidationErrorsMixin, {
  classNames: ['task'],

  _afterModel: Ember.on('init', function() {
    this.get('task').get('nestedQuestions');
    this.get('task').get('nestedQuestionAnswers');
  }),

  isMetadataTask: alias('task.isMetadataTask'),
  isSubmissionTask: alias('task.isSubmissionTask'),
  isSubmissionTaskEditable: alias('task.paper.editable'),
  isSubmissionTaskNotEditable: computed.not('task.paper.editable'),
  isEditable: computed.or('isUserEditable', 'currentUser.siteAdmin'),
  isUserEditable: computed('task.paper.editable', 'isSubmissionTask', function() {
    return this.get('task.paper.editable') || !this.get('isSubmissionTask');
  }),

  save() {
    return this.get('task').save().then(()=> {
      this.clearAllValidationErrors();
    }, (response) => {
      this.displayValidationErrorsFromResponse(response);
      this.set('task.completed', false);
    });
  },

  actions: {
    save() { return this.save(); }
  }
});
