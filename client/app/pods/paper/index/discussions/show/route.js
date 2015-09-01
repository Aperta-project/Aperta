import Ember from 'ember';
import DiscussionsShowRouteMixin from 'tahi/mixins/discussions/show/route';

export default Ember.Route.extend(DiscussionsShowRouteMixin, {
  // required to generate route paths:
  subRouteName: 'edit'
});
