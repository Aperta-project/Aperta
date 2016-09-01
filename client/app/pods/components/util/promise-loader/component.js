import Ember from 'ember';

export default Ember.Component.extend({
  promiseTask: null, // an ember-concurrency task

  init() {
    this._super(...arguments);
    this.get('promiseTask').perform();
  }
});
