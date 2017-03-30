import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-content-radio'],
  content: null,
  disabled: null,
  answer: null,

  init() {
    this._super(...arguments);

    Ember.assert(
      `the content must define an array of possibleValues
      that contains at least one object with the shape { label, value } `,
      Ember.isPresent(this.get('content.possibleValues'))
    );
  },

  actions: {
    valueChanged(newVal) {
      let action = this.get('valueChanged');
      if (action) {
        action(newVal);
      }
    }
  }
});
