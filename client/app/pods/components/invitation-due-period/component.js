import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNames: ['invitation-item-due'],
  validations: { dueIn: ['number'] },
  errored: Ember.computed.notEmpty('validationErrors.dueIn'),
  actions: {
    noop(){},
    onInputChange: function (event) {
      this.clearAllValidationErrors();
      if (this.get('value') < 1) { this.set('value', 1); }
      this.validate('dueIn', this.get('value'));
      if (this.get('onchange')) { this.get('onchange')(event); }
    }
  }
});
