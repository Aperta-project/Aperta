import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    close() {
      this.transitionToRoute('paper', this.get('model.paper'));
    }
  }
});
