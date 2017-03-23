import Ember from 'ember';

export default Ember.Component.extend({
  decision: null, // pass in an ember-data Decision

  // States:
  folded: true,

  classNames: ['decision-bar'],

  actions: {
    fold() {
      this.set('folded', !this.get('folded'));
    }
  }
});
