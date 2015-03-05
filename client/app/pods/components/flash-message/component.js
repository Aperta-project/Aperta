import Ember from 'ember';

/* See app/services/flash.js for documentation */

export default Ember.Component.extend({
  classNames: ['flash-message'],
  classNameBindings: ['type'],
  layoutName: 'flash-message',

  type: function() {
    return 'flash-message--' + this.get('message.type');
  }.property('message.type'),

  fadeIn: function() {
    this.$().hide().fadeIn(250);
  }.on('didInsertElement'),

  actions: {
    remove() {
      this.$().fadeOut(()=> {
        this.sendAction('remove', this.get('message'));
      });
    }
  }
});
