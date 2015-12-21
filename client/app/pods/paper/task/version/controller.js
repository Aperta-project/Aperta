import Ember from 'ember';

export default Ember.Controller.extend({
  queryParams: ['selectedVersion1', 'selectedVersion2'],

  actions: {
    close() {
      this.transitionToRoute('paper.versions', this.get('model.paper'));
    }
  }
});
