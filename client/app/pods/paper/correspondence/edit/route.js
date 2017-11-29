import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  model(params) {
    return this.store.findRecord('correspondence', params.correspondence_id);
  }
});