import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  model(params) {
    return this.store.findRecord('discussion-topic', params.topic_id);
  },

  setupController(controller, model) {
    this._super(controller, model);
    model.reload();
  },
});
