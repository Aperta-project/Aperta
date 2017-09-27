import Ember from 'ember';

export default Ember.Mixin.create({
  store: Ember.inject.service(),
  participations: Ember.computed.alias('task.participations'),
  participants: Ember.computed('participations.@each.user', function() {
    return this.get('participations').mapBy('user');
  }),
  users: [], // TO DO

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
    saveNewParticipant(newParticipant) {
      const user = this.get('store').findOrPush('user', newParticipant);
      if (this.get('participants').includes(user)) { return; }
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
