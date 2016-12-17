import Ember from 'ember';

/* See app/services/flash.js for documentation */

export default Ember.Component.extend({
  classNames: ['flash-messages'],

  didInsertElement() {
    if (this.get('flash')) {
      this.get('flash').set('flashMessagesComponentRendered', true);
    }
  },

  actions: {
    removeMessage(message) {
      this.flash.removeMessage(message);
    }
  }
});
