import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions-route-paths';

export default Ember.Controller.extend(DiscussionsRoutePathsMixin, {
  // required by DiscussionsRoutePathsMixin:
  subRouteName: 'workflow',

  participants: Ember.computed('model.discussionParticipants.@each.user', function() {
    return this.get('model.discussionParticipants').mapBy('user');
  }),

  actions: {
    postReply(body) {
      this.store.createRecord('discussion-reply', {
        discussionTopic: this.get('model'),
        replier: this.get('currentUser'),
        body: body
      }).save();
    },

    removeParticipantByUserId(userId) {
      this.get('model.discussionParticipants')
          .findBy('user.id', userId)
          .destroyRecord();
    },

    addParticipantByUserId(userId) {
      this.store.find('user', userId).then((user) => {
        this.store.createRecord('discussion-participant', {
          discussionTopic: this.get('model'),
          user: user,
        }).save();
      });
    }
  }
});
