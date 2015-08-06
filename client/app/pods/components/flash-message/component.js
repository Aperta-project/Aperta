import Ember from 'ember';

/* See app/services/flash.js for documentation */

export default Ember.Component.extend({
  classNames: ['flash-message'],
  classNameBindings: ['type'],

  type: Ember.computed('message.type', function() {
    return 'flash-message--' + this.get('message.type');
  }),

  fadeIn: Ember.on('didInsertElement', function() {
    this.$().hide().fadeIn(250);
  }),

  actions: {
    remove() {
      this.$().fadeOut(()=> {
        this.sendAction('remove', this.get('message'));
      });
    }
  }
});
