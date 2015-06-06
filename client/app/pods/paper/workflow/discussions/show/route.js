import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.find('discussion-topic', params.topic_id);
  },

  afterModel(model) {
    // NO
    model.reload();
  },

  setupController(controller, model) {
    this._super(controller, model);
    controller.set('participants', [this.get('currentUser')]);
  },
});
