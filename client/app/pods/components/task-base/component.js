import Ember from 'ember';
import Participants from 'tahi/mixins/controllers/controller-participants';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

const { computed } = Ember;
const { alias } = computed;

export default Ember.Component.extend(Participants, ValidationErrorsMixin, {
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
  isUserEditable: computed('task.paper.editable', 'isSubmissionTask',
    function() {
      return this.get('task.paper.editable') || !this.get('isSubmissionTask');
    }
  ),

  save() {
    return this.get('task').save().then(()=> {
      this.clearAllValidationErrors();
    }, (response) => {
      this.displayValidationErrorsFromResponse(response);
      this.set('task.completed', false);
    });
  },

  actions: {
    save()  { return this.save(); },
    close() {
      this.attrs.close();
    }
  }
});
