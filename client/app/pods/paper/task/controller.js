import Ember from 'ember';
import SavesDelayed from 'tahi/mixins/controllers/saves-delayed';
import ControllerParticipants from 'tahi/mixins/controllers/controller-participants';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

let alias = Ember.computed.alias;

export default Ember.Controller.extend(
  SavesDelayed, ControllerParticipants, ValidationErrorsMixin, Ember.Evented, {

  needs: ['application'],
  queryParams: ['isNewTask'],
  isNewTask: false,
  onClose: 'closeOverlay',
  isLoading: false,
  redirectStack: alias('controllers.application.overlayRedirect'),

  isMetadataTask: alias('model.isMetadataTask'),
  isSubmissionTask: alias('model.isSubmissionTask'),
  isEditable: Ember.computed.or('isUserEditable', 'isCurrentUserAdmin'),
  isCurrentUserAdmin: alias('currentUser.siteAdmin'),
  isUserEditable: Ember.computed(
    'model.paper.editable', 'isSubmissionTask', function() {
    return this.get('model.paper.editable') || !this.get('isSubmissionTask');
  }),

  comments: [],

  clearCachedModel(transition) {
    let redirectStack = this.get('redirectStack');

    if (!Ember.isEmpty(redirectStack)) {
      let redirectRoute = redirectStack.popObject();
      if (transition.targetName !== redirectRoute.get('firstObject')) {
        this.get('controllers.application').set('cachedModel', null);
      }
    }
  },

  saveModel() {
    this._super().then(()=> {
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
        this, this.get('controllers.application.overlayRedirect.lastObject')
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
