import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  init(){
    this._super(...arguments);
    this.set('stubInvitee', Ember.Object.create());
  },
  fields: Ember.A(['firstName', 'lastName']),
  actions: {
    cancelAccept(){
      if (this.get('loading')) { return; }
      this.clearAllValidationErrors();
      this.set('stubInvitee', Ember.Object.create());
      this.get('cancelAccept')();
    },
    confirmAccept(){
      this.clearAllValidationErrors();
      this.get('fields').forEach((field) => {
        if (!this.get(`stubInvitee.${field}`)) {
          this.displayValidationError(field, 'This field is required');
        }
      });
      if (this.validationErrorsPresent()) { return; }
      this.get('acceptInvitation')(this.get('stubInvitee'));
    }
  }
});
