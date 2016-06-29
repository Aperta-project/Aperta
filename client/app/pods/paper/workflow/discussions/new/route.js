import Ember from 'ember';
import DiscussionsNewRouteMixin from 'tahi/mixins/discussions/new/route';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend(DiscussionsNewRouteMixin, {
  // required to generate route paths:
  subRouteName: 'workflow'
});
