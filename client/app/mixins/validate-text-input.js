import Ember from 'ember';

export default Ember.Mixin.create({
  answerProxy: null,

  init() {
    // in case this input has no answer, a workingValue needs to be manually passed to the component
    this._super(...arguments);
    let value = this.get('answer.value');
    this.set('answerProxy', value);
  },

  actions: {
    valueChanged(newValue) {
      //in effect, this makes `answerProxy` a computed on answer.value
      this.set('answerProxy', newValue);
      // Hide error messages if field is blank
      if (Ember.isBlank(newValue) || newValue === '<p></p>') this.set('hideError', true);

      // If there were no previous errors, don't save to rails while typing
      if (this.get('answer.hasErrors')) {
        let action = this.get('valueChanged');
        if (action) { action(this.get('answerProxy')); }
      }
    },

    validate() {
      // Triggered on input blur. AnswerProxy is needed becasue blur does not pass the field's value
      this.set('hideError', false);
      let action = this.get('valueChanged');
      if (action) { action(this.get('answerProxy')); }
    }
  }
});
