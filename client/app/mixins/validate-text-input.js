import Ember from 'ember';

export default Ember.Mixin.create({
  answerProxy: null,
  hideError: true,

  init() {
    // Answerproxy avoids having the input 2-way bind with answer.value
    this._super(...arguments);
    this.set('answerProxy', this.get('answer.value'));
  },

  actions: {
    valueChanged(newValue) {
      //in effect, this makes `answerProxy` a computed on answer.value
      this.set('answerProxy', newValue);
      // Hide error messages if field is blank
      if (Ember.isBlank(newValue) || newValue === '<p></p>') this.set('hideError', true);

      let action = this.get('valueChanged');
      if (action) { action(newValue); }
    },

    displayErrors() {
      // All persistence done on input. Show errors once user focuses out.
      this.set('hideError', false);
    }
  }
});
