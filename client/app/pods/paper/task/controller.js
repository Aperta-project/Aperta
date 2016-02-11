import Ember from 'ember';
import SavesDelayed from 'tahi/mixins/controllers/saves-delayed';
import ValidationErrors from 'tahi/mixins/validation-errors';

const ABORT_CONFIRM_TEXT =
  'You are uploading, are you sure you want to abort uploading?';

export default Ember.Controller.extend(
  SavesDelayed, ValidationErrors, Ember.Evented, {

  queryParams: ['isNewTask'],
  isNewTask: false,
  isLoading: false,

  comments: [],

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
