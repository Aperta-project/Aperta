import Ember from 'ember';

export default Ember.Mixin.create({
  store: Ember.inject.service(),
  participations: Ember.computed.alias('task.participations'),
  participants: Ember.computed('participations.@each.user', function() {
    return this.get('participations').mapBy('user');
  }),

  findParticipation(participantId) {
    return this.get('participations').findBy('user.id', '' + participantId);
  },

  createNewParticipation(user, task) {
    return this.get('store').createRecord('participation', {
      user: user,
      task: task
    });
  },

  actions: {
    saveNewParticipant(newParticipant, availableParticipants) {
      let participant = availableParticipants.findBy('id', newParticipant.id);
      let user = this.get('store').findOrPush('user', participant);

      if (this.get('participants').contains(user)) { return; }

      this.createNewParticipation(user, this.get('task')).save();
    },

    removeParticipant(participantId) {
      const participant = this.findParticipation(participantId);
      if (!participant) { return; }

      participant.deleteRecord();
      participant.save();
    }
  }
});
