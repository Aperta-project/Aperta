import Ember from 'ember';

export default Ember.Controller.extend({
  participants: [],
  allUsers: [],

  actions: {
    postReply(body) {
      let reply = this.get('model.replies').createRecord({
        replier: this.get('currentUser'),
        body: body
      });
    },

    removeParticipant(participant) {
    },

    addParticipantById(id) {
    }
  }
});
