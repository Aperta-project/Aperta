import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions-route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  actions: {
    hideDiscussions() {
      this.transitionTo(this.get('topicsParentPath'));
    }
  }
});
