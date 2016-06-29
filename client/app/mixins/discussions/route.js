import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  subscribedTopics: [],

  model() {
    const paper = this.modelFor('paper');
    return Ember.RSVP.hash({
        atMentionableStaffUsers: paper.atMentionableStaffUsers()
    });
  },

  actions: {
    hideDiscussions() {
      this.transitionTo(this.get('topicsParentPath'));
    }
  }
});
