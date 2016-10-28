import Ember from 'ember';

export default Ember.Component.extend({
  concurrencyTask: null, // an ember-concurrency task

  init() {
    this._super(...arguments);
    this.get('concurrencyTask').perform();
  }
});
