import Ember from 'ember';

export default Ember.Component.extend({
  value: null,
  placeholder: null,
  label: null,
  errors: [],
  enter: null,

  classNames: ['labeled-input-with-errors'],

  errorPresent: Ember.computed.notEmpty('errors'),

  actions: {
    enter() {
      const enter = this.get('enter');
      if (enter) enter();
    }
  }
});
