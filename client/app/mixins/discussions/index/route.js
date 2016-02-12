import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {

  model() {
    return this.topicsFromStore();
  },

  topicsFromStore() {
    return this.store.all('discussion-topic');
  },

  setupController(controller, model) {
    this._super(controller, model);
    controller.set('paper', this.modelFor('paper'))
  },

});
