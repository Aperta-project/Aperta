import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  validations: { dueIn: ['number'] },
  errored: Ember.computed.notEmpty('validationErrors.dueIn'),
  actions: {
    onInputChange: function (event) {
      this.clearAllValidationErrors();
      this.validate('dueIn', event.target.value);
      if (this.get('onchange')) { this.get('onchange')(event); }
    }
  }
});
