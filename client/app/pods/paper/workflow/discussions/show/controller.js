import Ember from 'ember';

export default Ember.Controller.extend({
  participants: Ember.computed('model.discussionParticipants.@each', function() {
    return this.get('model.discussionParticipants').map(function(part) {
      return part.get('user');
    });
  }),

  allUsers: [],

  actions: {
    postReply(body) {
      this.store.createRecord('discussion-reply', {
        discussionTopic: this.get('model'),
        replier: this.get('currentUser'),
        body: body
      }).save();
    },

    removeParticipantByUserId(userId) {
      console.log("if this worked, it would remove the participant... :|");
      // this.store.find('discussion-participant', {
      //   discussionTopicId: this.get('model.id'),
      //   userId: userId,
      // }).then( (participant) => {
      //   participant.destroyRecord();
      // });
    },

    addParticipantByUserId(userId) {
      console.log("adding user#" + userId + " to the discussion!");
      this.store.find('user', userId).then( (user) => {
        this.store.createRecord('discussion-participant', {
          discussionTopic: this.get('model'),
          user: user,
        }).save();
      });
    }
  }
});
