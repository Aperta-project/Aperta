import Ember from 'ember';
import DiscussionsIndexRouteMixin from 'tahi/mixins/discussions/index/route';

export default Ember.Route.extend(DiscussionsIndexRouteMixin, {

  paperModel(){
    return this.modelFor('discussions.paper');
  },

  // required to generate route paths:
  topicsBasePath() {
    return 'discussions.paper.';
  },

  activate() {
    this.send('updateRoute', 'index');
    this.send('updateDiscussionId', null);
  }
});
