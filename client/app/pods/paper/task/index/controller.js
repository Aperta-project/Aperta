import Ember from 'ember';

export default Ember.Controller.extend({
  restless: Ember.inject.service(),
  
  actions: {
    close() {
      this.transitionToRoute('paper', this.get('model.paper.shortDoi'));
    }
  }
});
