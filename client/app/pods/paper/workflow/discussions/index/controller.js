import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions-route-paths';

export default Ember.Controller.extend(DiscussionsRoutePathsMixin, {
  // required by DiscussionsRoutePathsMixin:
  subRouteName: 'workflow'
});
