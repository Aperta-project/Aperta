import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions-route-paths';

export default Ember.Route.extend(DiscussionsRoutePathsMixin, {
  // required by DiscussionsRoutePathsMixin:
  subRouteName: 'workflow',

  actions: {
    hideDiscussions() {
      this.transitionTo(this.get('topicsParentPath'));
    }
  }
});
