import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {

  model() {
    return this.paperModel().get('discussionTopics');
  },

  paperModel() {
    return this.modelFor('paper');
  },

  setupController(controller, model) {
    model.reload();
    this._super(controller, model);
    controller.set('paper', this.paperModel());
  }
});
