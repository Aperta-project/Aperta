import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.topicsFromStore();
  },

  setupController(controller, model) {
    this._super(controller, model);

    this.topicsFromServer().then(function(records){
      controller.set('model', records);
    });
  },

  topicsFromStore() {
    return this.store.all('discussion-topic').filterBy('paperId', this.modelFor('paper').get('id'));
  },

  topicsFromServer() {
    return this.store.find('discussion-topic', {
      paper_id: this.modelFor('paper').get('id')
    });
  }
});
