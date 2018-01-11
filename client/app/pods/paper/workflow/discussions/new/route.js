import DiscussionsNewRouteMixin from 'tahi/mixins/discussions/new/route';
import AuthorizedRoute from 'tahi/pods/authorized/route';

export default AuthorizedRoute.extend(DiscussionsNewRouteMixin, {
  // required to generate route paths:
  subRouteName: 'workflow'
});
