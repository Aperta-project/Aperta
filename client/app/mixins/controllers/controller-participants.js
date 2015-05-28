import Ember from 'ember';

export default Ember.Mixin.create({
  needs: ['application'],
  currentUser: Ember.computed.alias('controllers.application.currentUser'),
  participations: [],

  participants: function() {
    return this.get('participations').mapBy('user');
  }.property('participations.@each.user'),

  createParticipant(newParticipant) {
    if (newParticipant && !this.get('participants').contains(newParticipant)) {
      return this.store.createRecord('participation', {
        user: newParticipant,
        task: this.get('model')
      });
    }
  },

  findParticipation(participantId) {
    return this.get('participations').findBy('user.id', participantId);
  },

  actions: {
    saveNewParticipant(newParticipantId) {
      let that = this
      this.store.find('user', newParticipantId).then(function(user) {
        let part = that.createParticipant(user);
        if (!part) { return; }

        if (!that.get('model.isNew')) {
          return part.save();
        }
      });
    },

    removeParticipant(participantId) {
      let part = this.findParticipation('' + participantId);
      if (!part) { return; }

      part.deleteRecord();
      if (!this.get('model.isNew')) {
        return part.save();
      }
    }
  }
});
