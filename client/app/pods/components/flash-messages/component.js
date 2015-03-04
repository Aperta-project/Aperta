import Ember from 'ember';

/* See app/services/flash.js for documentation */

export default Ember.Component.extend({
  classNames: ['flash-messages'],
  layoutName:  'flash-messages',

  actions: {
    removeMessage: function(message) {
      this.flash.removeMessage(message);
    }
  }
});
