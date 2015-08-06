import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['error-message'],
  classNameBindings: ['visible'],

  visible: Ember.computed('message', function() {
    return this.get('message') ? '' : 'error-message--hidden';
  })
});
