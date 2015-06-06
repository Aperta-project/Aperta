import Ember from 'ember';

export default Ember.Controller.extend({
  participants: [],
  allUsers: [],

  actions: {
    postReply(body) {
      this.store.createRecord('discussion-reply', {
        discussionTopic: this.get('model'),
        replier: this.get('currentUser'),
        body: body
      }).save();
    },

    removeParticipant(participant) {
    },

    addParticipantById(id) {
    }
  }
});
