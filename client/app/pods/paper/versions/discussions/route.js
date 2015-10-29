import Ember from 'ember';
import DiscussionsRouteMixin from 'tahi/mixins/discussions/route';

export default Ember.Route.extend(DiscussionsRouteMixin, {
  // required to generate route paths:
  subRouteName: 'index'
});
