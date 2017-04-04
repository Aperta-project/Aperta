import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-content-short-input'],
  content: null,
  disabled: null,
  answer: null,

  actions: {
    valueChanged(e) {
      let action = this.get('valueChanged');
      if (action) {
        action(e.target.value);
      }
    }
  }
});
