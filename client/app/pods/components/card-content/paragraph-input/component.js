import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-content-paragraph-input'],
  content: null,
  disabled: null,
  answer: null,

  actions: {
    valueChanged(newValue) {
      let action = this.get('valueChanged');
      if (action) {
        action(newValue);
      }
    }
  }
});
