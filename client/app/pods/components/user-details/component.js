import Ember from 'ember';
import VEMixin from 'tahi/mixins/validation-errors';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(VEMixin, EscapeListenerMixin, {
  actions: {
    saveUser() {
      this.get('model').save().then(()=> {
        this.attrs.close();
      }).catch((response) => {
        this.displayValidationErrorsFromResponse(response);
      });
    },

    rollbackUser() {
      this.get('model').rollbackAttributes();
      this.attrs.close();
    },

    close() {
      this.attrs.close();
    }
  }
});
