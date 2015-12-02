import Ember from 'ember';
import SavesDelayed from 'tahi/mixins/controllers/saves-delayed';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import ControllerParticipants from
  'tahi/mixins/controllers/controller-participants';

const ABORT_CONFIRM_TEXT =
  'You are uploading, are you sure you want to abort uploading?';

const { computed } = Ember;
const { alias, not } = computed;

export default Ember.Controller.extend(
  SavesDelayed, ControllerParticipants, ValidationErrorsMixin, Ember.Evented, {

  cardOverlayService: Ember.inject.service('card-overlay'),
  queryParams: ['isNewTask'],
  isNewTask: false,
  onClose: 'closeOverlay',
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

  clearCachedModel(transition) {
    const routeOptions = this.get('cardOverlayService.previousRouteOptions');

    if(Ember.isEmpty(routeOptions)) { return; }

    if (transition.targetName !== routeOptions.get('firstObject')) {
      this.set('cardOverlayService.cachedModel', null);
    }
  },

  saveModel() {
    return this._super().then(()=> {
      this.clearAllValidationErrors();
    }, (response) => {
      this.displayValidationErrorsFromResponse(response);
      this.set('model.completed', false);
      this.get('model').rollback();
    });
  },

  actions: {
    redirect() {
      this.transitionToRoute.apply(
        this, this.get('cardOverlayService.previousRouteOptions')
      );
    },

    redirectToDashboard() {
      this.transitionToRoute('dashboard');
    },

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

      this.clearCachedModel(transition);
      this.clearAllValidationErrors();
    }
  }
});
