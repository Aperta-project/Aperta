import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  task: DS.belongsTo('task', { polymorphic: true }),
  invitee: DS.belongsTo('user', { inverse: 'invitations' }),

  title: DS.attr('string'),
  abstract: DS.attr('string'),
  state: DS.attr('string'),
  email: DS.attr('string'),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),
  invitationType: DS.attr('string'),
  information: DS.attr('string'),

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
