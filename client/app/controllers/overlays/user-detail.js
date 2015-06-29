import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Controller.extend(ValidationErrorsMixin, {
  overlayClass: 'overlay--fullscreen user-detail-overlay',
  resetPasswordSuccess: false,
  resetPasswordFailure: false,

  actions: {
    saveUser() {
      this.get('model').save()
                       .then(()=> {
                         this.clearAllValidationErrors();
                         this.send('closeOverlay');
                       })
                       .catch((response) => {
                         this.displayValidationErrorsFromResponse(response);
                       });
    },

    rollbackUser() {
      this.get('model').rollbackAttributes();
      this.clearAllValidationErrors();
      this.send('closeOverlay');
    },

    resetPassword(user) {
      $.get(`/api/admin/journal_users/${user.get('id')}/reset`).always(()=> {
        this.set('resetPasswordSuccess', true);
      });
    }
  }
});
