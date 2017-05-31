import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  isUploading: false,
  close: null,

  actions: {
    uploadStarted() {},
    uploadFinished() {},
    submit(model) {
      model.save().then(() => {
        this.clearAllValidationErrors();
      }, (response) => {
        this.displayValidationErrorsFromResponse(response);
      }).finally(() => {
        this.sendAction('close');
      });
    }
  }
});
