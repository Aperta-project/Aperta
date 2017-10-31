import Ember from 'ember';

export default Ember.Mixin.create({

  init() {
    // in case this input has no answer, a workingValue needs to be manually passed to the component
    this._super(...arguments);
    let value = this.get('answer.value') || this.get('workingValue');
    this.set('answerProxy', value);
  },

  actions: {
    valueChanged(newValue) {
      //this is essentially functioning as setting `answerProxy` as a computed on asnwer.value
      this.set('answerProxy', newValue);
      // Hide error messages if field is blank
      if (Ember.isBlank(newValue) || newValue === '<p></p>') this.set('hideError', true);
      // If there were no previous errors, don't hit rails on change
      if (this.get('answer.hasErrors')) { this.send('validate'); }
    },

    validate() {
      // Triggered on blur. AnswerProxy is needed becasue blur does not pass the field's value
      this.set('hideError', false);
      let action = this.get('valueChanged');
      if (action) { action(this.get('answerProxy')); }
    }
  }
});
