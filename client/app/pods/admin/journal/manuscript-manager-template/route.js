import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    // Noop. We don't want to open cards in MMT screen
    viewCard() {}
  }
});
