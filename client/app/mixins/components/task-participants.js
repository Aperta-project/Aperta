/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
