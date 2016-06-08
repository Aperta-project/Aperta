import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  abstract: DS.attr('string'),
  body: DS.attr('string'),
  createdAt: DS.attr('date'),
  declineReason: DS.attr('string'),
  email: DS.attr('string'),
  information: DS.attr('string'),
  invitationType: DS.attr('string'),
  invitee: DS.belongsTo('user', { inverse: 'invitations', async: true }),
  inviteeRole: DS.attr('string'),
  reviewerSuggestions: DS.attr('string'),
  state: DS.attr('string'),
  task: DS.belongsTo('task', { polymorphic: true, async: true }),
  title: DS.attr('string'),
  updatedAt: DS.attr('date'),

  pendingFeedback: false,

  accepted: Ember.computed.equal('state', 'accepted'),

  reject() {
    this.set('state', 'rejected');
  },

  accept() {
    this.set('state', 'accepted');
  },

 restless: Ember.inject.service('restless'),
 rescind() {
   return this.get('restless')
    .put(`/api/invitations/${this.get('id')}/rescind`)
    .then((data) => {
      this.unloadRecord();
      return this;
    });
  },

  feedbackSent() {
    this.set('pendingFeedback', false);
  },

  declineFeedback() {
    this.set('declineReason', null);
    this.set('reviewerSuggestions', null);
    this.set('pendingFeedback', false);
  },

  invitationFeedbackIsBlank: Ember.computed(
    'reviewerSuggestions',
    'declineReason',
    function() {
      return Ember.isBlank(this.get('reviewerSuggestions')) &&
        Ember.isBlank(this.get('declineReason'));
  }),

  invited: Ember.computed.equal('state', 'invited'),
  rejected: Ember.computed.equal('state', 'rejected'),

  needsUserUpdate: Ember.computed.or('invited', 'pendingFeedback')
});
