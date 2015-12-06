import Ember from 'ember';

export default Ember.Mixin.create({
  participations: Ember.computed.alias('model.participations'),
  participants: Ember.computed('participations.@each.user', function() {
    return this.get('participations').mapBy('user');
  }),

  createParticipant(newParticipant) {
    return this.store.createRecord('participation', {
      user: newParticipant,
      task: this.get('model')
    });
  },

  findParticipation(participantId) {
    return this.get('participations').findBy('user.id', participantId);
  },

  actions: {
    saveNewParticipant(newParticipantId) {
      this.store.find('user', newParticipantId).then((user) => {
        if (this.get('participants').contains(user)) { return; }
        // TODO: Do we need this check? When is a task new?
        if (this.get('model.isNew')) { return; }
        this.createParticipant(user).save();
      });
    },

    removeParticipant(participantId) {
      const part = this.findParticipation('' + participantId);
      if (!part) { return; }

      part.deleteRecord();
      if (!this.get('model.isNew')) {
        return part.save();
      }
    }
  }
});
