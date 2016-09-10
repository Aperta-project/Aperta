import Ember from 'ember';

export default Ember.Component.extend({
  task: null, // an ember-concurrency task

  init() {
    this._super(...arguments);
    this.get('task').perform();
  }
});
