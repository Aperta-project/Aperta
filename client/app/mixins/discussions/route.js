import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  subscribedTopics: [],

  afterModel(model) {
    model.get('discussionTopics');
  },

  actions: {
    hideDiscussions() {
      this.transitionTo(this.get('topicsParentPath'));
    }
  }
});
