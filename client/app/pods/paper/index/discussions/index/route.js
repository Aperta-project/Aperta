import Ember from 'ember';
import DiscussionsIndexRouteMixin from 'tahi/mixins/discussions/index/route';

export default Ember.Route.extend(DiscussionsIndexRouteMixin, {
  // required to generate route paths:
  subRouteName: 'index'
});
