import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.find('discussion-topic', params.topic_id);
  },

  setupController(controller, model) {
    this._super(controller, model);
    model.reload();
    controller.set('participants', [this.get('currentUser')]);
  },
});
