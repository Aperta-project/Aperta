import Ember from 'ember';

export default Ember.Component.extend({
  classNames: [],
  card: null,
  showDescription: false,

  actions: {
    toggleDescription(v) {
      this.set('showDescription', v);
    }
  }
});
