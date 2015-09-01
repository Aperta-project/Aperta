import Ember from 'ember';
import DiscussionsNewRouteMixin from 'tahi/mixins/discussions/new/route';

export default Ember.Route.extend(DiscussionsNewRouteMixin, {
  // required to generate route paths:
  subRouteName: 'edit',

});
