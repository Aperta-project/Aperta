import Ember from 'ember';

/* See app/services/flash.js for documentation */

export default Ember.Component.extend({
  classNames: ['flash-messages'],

  actions: {
    removeRouteMessage(message) {
      this.flash.removeRouteLevelMessage(message);
    },
    removeSystemMessage(message) {
      this.flash.removeSystemLevelMessage(message);
    }
  }
});
