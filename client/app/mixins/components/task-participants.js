import Ember from 'ember';

export default Ember.Mixin.create({
  store: Ember.inject.service(),
  participations: Ember.computed.alias('task.participations'),

  participants: Ember.computed('participations.@each.user', function() {
    return this.get('participations').mapBy('user');
  }),
  assignedUser: Ember.computed('task.assignedUser', function() {
    let user = this.get('task.assignedUser');
    // It has to return an array because the participant-selector expects
    // currentParticipants to be kind of array.
    return user.get('id') ? [user] : [];
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
    saveAssignedUser(newUser) {
      const user = this.get('store').findOrPush('user', newUser);
      this.set('task.assignedUser', user);
      this.get('task').save();
    },

    saveNewParticipant(newParticipant) {
      const user = this.get('store').findOrPush('user', newParticipant);
      if (this.get('participants').includes(user)) { return; }
      this.createNewParticipation(user, this.get('task')).save();
    },

    removeAssignedUser() {
      this.set('task.assignedUser', null);
      this.get('task').save();
    },

    removeParticipant(participantId) {
      const participant = this.findParticipation(participantId);
      if (!participant) { return; }

      participant.deleteRecord();
      participant.save();
    }
  }
});
