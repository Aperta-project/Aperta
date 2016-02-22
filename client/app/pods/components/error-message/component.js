import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [ ':error-message', 'visible' ],

  displayIcon: false,
  displayText: true,

  visible: Ember.computed('message', function() {
    return this.get('message') ? '' : 'error-message--hidden';
  })
});
