import Ember from 'ember';
import DiscussionsShowRouteMixin from 'tahi/mixins/discussions/show/route';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend(DiscussionsShowRouteMixin, {
  // required to generate route paths:
  subRouteName: 'workflow',
});
