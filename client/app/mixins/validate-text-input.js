import Ember from 'ember';

export default Ember.Mixin.create({
  workingValue: null,
  init() {
    this._super(...arguments);
    let value = this.get('answer.value');
    // If workingValue is passed in to the component then don't
    // overwrite it with the value of answer.value
    if (value && value.length > 0) {
      this.set('workingValue', value);
    }
  },
  actions: {
    valueChanged(newValue) {
      this.set('workingValue', newValue);
      // Be nice to a user who is starting his answer over. This will hide the actual error
      // message, but will leave the input field's red border while there are still errors.
      if (Ember.isBlank(newValue) || newValue === '<p></p>') this.set('hideError', true);

      // If there were no previous errors, don't save to rails while typing.
      if (!this.get('answer.hasErrors')) return;

      let action = this.get('valueChanged');
      if (action) {
        action(newValue);
      }
    },

    validate() {
      // This gets triggered on blur, which won't pass us the input field's payload, but
      // fortunately we've been setting it to Ember on each value change.
      let workingValue = this.get('workingValue');
      // Show any errors we might have been hiding while the user typed.
      this.set('hideError', false);

      let action = this.get('valueChanged');
      if (action) {
        action(workingValue);
      }
    }
  }
});
