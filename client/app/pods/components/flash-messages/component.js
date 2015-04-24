import Ember from 'ember';

/* See app/services/flash.js for documentation */

export default Ember.Component.extend({
  classNames: ['flash-messages'],
  layoutName:  'flash-messages',

  actions: {
    removeMessage(message) {
      this.flash.removeMessage(message);
    }
  }
});
