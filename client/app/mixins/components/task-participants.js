import Ember from 'ember';

export default Ember.Mixin.create({
  participations: Ember.computed.alias('task.participations.content.[]'),
  participants: Ember.computed('participations.@each.user', function() {
    return this.get('participations').mapBy('user');
  }),

  getStore() {
    return this.container.lookup('store:main');
  },

  findParticipation(participantId) {
    return this.get('participations').findBy('user.id', '' + participantId);
  },

  createNewParticipation(user, task) {
    return this.getStore().createRecord('participation', {
      user: user,
      task: task
    });
  },

  actions: {
    saveNewParticipant(newParticipantId) {
      this.getStore().find('user', newParticipantId).then((user) => {
        if (this.get('participants').contains(user)) { return; }

        this.createNewParticipation(user, this.get('task'))
            .save();
      });
    },

    removeParticipant(participantId) {
      const participant = this.findParticipation(participantId);
      if (!participant) { return; }

      participant.deleteRecord();
      participant.save();
    }
  }
});
