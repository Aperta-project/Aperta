import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  task: DS.belongsTo('task', { polymorphic: true }),
  title: DS.attr('string'),
  abstract: DS.attr('string'),
  state: DS.attr('string'),
  email: DS.attr('string'),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),
  invitationType: DS.attr('string'),
  inviteeId: DS.attr('string'),
  inviteeFullName: DS.attr('string'),
  inviteeAvatarUrl: DS.attr('string'),

  invitee: Ember.computed('inviteeFullName', 'inviteeAvatarUrl', function() {
    return Ember.Object.create({
      avatarUrl: this.get('inviteeAvatarUrl'),
      name: this.get('inviteeFullName')
    });
  }),

  accepted: Ember.computed('state', function() {
    return this.get('state') === 'accepted';
  }),

  reject() {
    this.set('state', 'rejected');
  },

  accept() {
    this.set('state', 'accepted');
  }
});
