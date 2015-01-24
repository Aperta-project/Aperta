import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['flash-messages'],
  layoutName:  'flash-messages',

  actions: {
    removeMessage: function(message) {
      this.get('flash.messages').removeObject(message);
    }
  }
});
