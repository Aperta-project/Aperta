import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';

export default Ember.Mixin.create({
  participations: Ember.computed.alias('task.participations'),
  participants: Ember.computed('participations.@each.user', function() {
    return this.get('participations').mapBy('user');
  }),

  getStore() {
    return getOwner(this).lookup('store:main');
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
    saveNewParticipant(newParticipant, availableParticipants) {
      let participant = availableParticipants.findBy('id', newParticipant.id);
      let user = this.getStore().findOrPush('user', participant);

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
