import Ember from 'ember';

export default Ember.Mixin.create({
  workingValue: null,

  init() {
    this._super(...arguments);
    let value = this.get('answer.value');
    // If there is a value, make it the workingValue
    if (value && value.length > 0) {
      this.set('workingValue', value);
    }
  },

  actions: {
    valueChanged(newValue) {
      this.set('workingValue', newValue);
      // Hide error messages if field is blank
      if (Ember.isBlank(newValue) || newValue === '<p></p>') this.set('hideError', true);
      // If there were no previous errors, don't hit rails on change
      if (this.get('answer.hasErrors')) { this.send('validate'); }
    },

    validate() {
      // Triggered on blur. This doesn't pass the field's current value so we use workingValue
      this.set('hideError', false);

      let action = this.get('valueChanged');
      if (action) { action(this.get('workingValue')); }
    }
  }
});
