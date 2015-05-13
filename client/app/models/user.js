import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  affiliations: DS.hasMany('affiliation'),
  invitations: DS.hasMany('invitation', { inverse: 'invitee' }),

  avatarUrl: DS.attr('string'),
  email: DS.attr('string'),
  firstName: DS.attr('string'),
  fullName: DS.attr('string'),
  siteAdmin: DS.attr('boolean'),
  username: DS.attr('string'),

  name: Ember.computed.alias('fullName'),
  affiliationSort: ['isCurrent:desc', 'endDate:desc', 'startDate:asc'],
  affiliationsByDate: Ember.computed.sort('affiliations', 'affiliationSort'),

  invitedInvitations: function() {
    return this.get('invitations').filterBy('state', 'invited');
  }.property('invitations.@each.state')
});
