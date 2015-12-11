import Ember from 'ember';
import SavesDelayed from 'tahi/mixins/controllers/saves-delayed';
import ValidationErrors from 'tahi/mixins/validation-errors';

const ABORT_CONFIRM_TEXT =
  'You are uploading, are you sure you want to abort uploading?';

const { computed } = Ember;
const { alias, not } = computed;

export default Ember.Controller.extend(
  SavesDelayed, ValidationErrors, Ember.Evented, {

  queryParams: ['isNewTask'],
  isNewTask: false,
  isLoading: false,

  isMetadataTask: alias('model.isMetadataTask'),
  isSubmissionTask: alias('model.isSubmissionTask'),
  isSubmissionTaskEditable: alias('model.paper.editable'),
  isSubmissionTaskNotEditable: not('model.paper.editable'),
  isEditable: computed.or('isUserEditable', 'currentUser.siteAdmin'),
  isUserEditable: computed(
    'model.paper.editable', 'isSubmissionTask', function() {
      return this.get('model.paper.editable') || !this.get('isSubmissionTask');
    }
  ),

  comments: [],

  saveModel() {
    return this._super().then(()=> {
      this.clearAllValidationErrors();
    }, (response) => {
      this.displayValidationErrorsFromResponse(response);
      this.set('model.completed', false);
    });
  },

  actions: {
    postComment(body) {
      if (!body) { return; }

      const commentFields = {
        commenter: this.currentUser,
        task: this.get('model'),
        body: body,
        createdAt: new Date()
      };

      const newComment = this.store.createRecord('comment', commentFields);

      newComment.save();
    },

    routeWillTransition(transition) {
      if (this.get('isUploading')) {
        if (window.confirm(ABORT_CONFIRM_TEXT)) {
          this.send('cancelUploads');
        } else {
          transition.abort();
          return;
        }
      }

      this.clearAllValidationErrors();
    }
  }
});
