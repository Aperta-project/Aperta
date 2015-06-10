import Ember from 'ember';

export default Ember.Controller.extend({
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
      let participant = this.get('model.discussionParticipants').findBy('user.id', userId);
      participant.destroyRecord();
    },

    addParticipantByUserId(userId) {
      this.store.find('user', userId).then( (user) => {
        this.store.createRecord('discussion-participant', {
          discussionTopic: this.get('model'),
          user: user,
        }).save();
      });
    }
  }
});
