import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [ ':error-message', 'visible', 'indent::error-message--no-indent'],

  message: '',
  displayIcon: false,
  displayText: true,
  indent: true,

  visible: Ember.computed('message', function() {
    return this.get('message') ? '' : 'error-message--hidden';
  })
});
