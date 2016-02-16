import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [ ':error-message', 'visible' ],

  icon: false,
  text: true,

  visible: Ember.computed('message', function() {
    return this.get('message') ? '' : 'error-message--hidden';
  })
});
