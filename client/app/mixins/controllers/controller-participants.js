import Ember from 'ember';

export default Ember.Mixin.create({
  participations: [],

  participants: Ember.computed('participations.@each.user', function() {
    return this.get('participations').mapBy('user');
  }),

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
      this.store.findRecord('user', newParticipantId).then((user) => {
        let part = this.createParticipant(user);
        if (!part) { return; }

        if (!this.get('model.isNew')) {
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
