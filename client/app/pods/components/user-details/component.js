import Ember from 'ember';
import VEMixin from 'tahi/mixins/validation-errors';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(VEMixin, EscapeListenerMixin, {
  resetPasswordSuccess: false,
  resetPasswordFailure: false,

  actions: {
    saveUser() {
      this.get('model').save().then(()=> {
        this.attrs.close();
      }).catch((response) => {
        this.displayValidationErrorsFromResponse(response);
      });
    },

    rollbackUser() {
      this.get('model').rollback();
      this.attrs.close();
    },

    resetPassword(user) {
      $.get(`/api/admin/journal_users/${user.get('id')}/reset`).always(()=> {
        this.set('resetPasswordSuccess', true);
      });
    },

    close() {
      this.attrs.close();
    }
  }
});
