import Ember from 'ember';
import SavesDelayed from 'tahi/mixins/controllers/saves-delayed';
import ControllerParticipants from 'tahi/mixins/controllers/controller-participants';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

let alias = Ember.computed.alias;

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
  isSubmissionTaskNotEditable: Ember.computed.not('model.paper.editable'),
  isEditable: Ember.computed.or('isUserEditable', 'currentUser.siteAdmin'),
  isUserEditable: Ember.computed('model.paper.editable', 'isSubmissionTask', function() {
    return this.get('model.paper.editable') || !this.get('isSubmissionTask');
  }),

  comments: [],

  clearCachedModel(transition) {
    let routeOptions = this.get('cardOverlayService.previousRouteOptions');

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
    });
  },

  actions: {
    closeAction() {
      this.send(this.get('onClose'));
    },

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

      let commentFields = {
        commenter: this.currentUser,
        task: this.get('model'),
        body: body,
        createdAt: new Date()
      };

      let newComment = this.store.createRecord('comment', commentFields);

      newComment.save();
    },

    routeWillTransition(transition) {
      if (this.get('isUploading')) {
        if (confirm('You are uploading, are you sure you want to abort uploading?')) {
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
