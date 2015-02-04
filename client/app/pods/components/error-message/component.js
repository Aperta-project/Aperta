import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['error-message'],
  classNameBindings: ['visible'],
  layoutName: 'error-message',

  visible: function() {
    return this.get('message') ? '' : 'error-message--hidden';
  }.property('message')
});
