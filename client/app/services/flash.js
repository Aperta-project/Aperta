import Ember from 'ember';

export default Ember.Object.extend({
  messages: [],

  displayMessage: function(type, message) {
    this.get('messages').pushObject({
      text: message,
      type: type
    });
  },

  displayErrorMessagesFromResponse: function(response) {
    for (var key in response.errors) {
      if(!response.errors.hasOwnProperty(key)) { continue; }
      this.displayMessage('error', this.formatKey(key) + ' ' + response.errors[key].join(', '));
    }
  },

  formatKey: function(key) {
    return key.underscore().replace('_', ' ').capitalize();
  },

  clearMessages: function() {
    this.set('messages', []);
  }
});
