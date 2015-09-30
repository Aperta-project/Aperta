import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['error-message'],
  classNameBindings: ['visible', 'addPassedClass'],

  visible: Ember.computed('message', function() {
    return this.get('message') ? '' : 'error-message--hidden';
  }),

  addPassedClass: Ember.computed(function() {
    return this.get('class') ? this.get('class') : '';
  })
});
