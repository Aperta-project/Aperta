import Ember from 'ember';

export default Ember.Component.extend({
  version: null,
  folded: true,

  classNames: ['similarity-check-bar'],

  actions: {
    fold() {
      this.set('folded', !this.get('folded'));
    }
  }
});
