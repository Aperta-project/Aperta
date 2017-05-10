import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  subscribedTopics: [],
  popoutParent: Ember.inject.service(),
  popoutRoute: 'index',
  popoutDiscussionId: null,
  popoutParams: { width: 900 },

  model() {
    const paper = this.modelFor('paper');
    return Ember.RSVP.hash({
      atMentionableStaffUsers: paper.atMentionableStaffUsers()
    });
  },

  activate() {
    this.set('popoutRoute', 'index');
    this.set('popoutDiscussionId', null);
  },

  actions: {
    popOutDiscussions() {
      let paperId = this.modelFor('paper').id;
      let popoutParent = this.get('popoutParent');

      if (this.get('popoutDiscussionId') === null ) {
        popoutParent.open(paperId,'discussions.paper.' + this.get('popoutRoute'),
                          paperId, this.get('popoutParams'));
      } else {
        popoutParent.open(paperId,'discussions.paper.' + this.get('popoutRoute'),
                          paperId,this.get('popoutDiscussionId'),
                          this.get('popoutParams'));
      }
      this.send('hideDiscussions');
    },

    updatePopoutRoute(route) {
      this.set('popoutRoute', route);
    },

    updateDiscussionId(id) {
      this.set('popoutDiscussionId',id);
    },

    hideDiscussions() {
      this.transitionTo(this.get('topicsParentPath'));
    }
  }
});
