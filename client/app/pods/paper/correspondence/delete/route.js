import AuthorizedRoute from 'tahi/pods/authorized/route';

export default AuthorizedRoute.extend({
  model(params) {
    return this.store.findRecord('correspondence', params.correspondence_id);
  }
});
