import DiscussionsShowRouteMixin from 'tahi/mixins/discussions/show/route';
import AuthorizedRoute from 'tahi/pods/authorized/route';

export default AuthorizedRoute.extend(DiscussionsShowRouteMixin, {
  // required to generate route paths:
  subRouteName: 'correspondence',
});
