import Ember from 'ember';
export default Ember.Controller.extend({
  queryParams: ['majorVersion', 'minorVersion'],

  actions: {
    close() {
      this.transitionToRoute('paper.versions', this.get('model.paper'));
    }
  }
});
