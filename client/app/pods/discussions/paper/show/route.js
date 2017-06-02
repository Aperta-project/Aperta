import Ember from 'ember';
import DiscussionsShowRouteMixin from 'tahi/mixins/discussions/show/route';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend(DiscussionsShowRouteMixin, {
  paperModel(){
    return this.modelFor('discussions.paper');
  },

  // required to generate route paths:
  makeBasePath() {
    return 'discussions.paper';
  },

  activate() {
    this.send('updateRoute', 'show');
    this.send('updateDiscussionId', this.get('modelId'));
  },
});
