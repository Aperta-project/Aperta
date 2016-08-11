import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  abstract: DS.attr('string'),
  attachments: DS.hasMany('attachment', { polymorphic: true, async: true }),
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
  pending: Ember.computed.equal('state', 'pending'),

  invitationFeedbackIsBlank: Ember.computed(
    'reviewerSuggestions',
    'declineReason',
    function() {
      return Ember.isBlank(this.get('reviewerSuggestions')) &&
        Ember.isBlank(this.get('declineReason'));
    }
  ),

  invited: Ember.computed.equal('state', 'invited'),
  needsUserUpdate: Ember.computed.or('invited', 'pendingFeedback'),
  declined: Ember.computed.equal('state', 'declined'),

  setDeclined() {
    this.set('state', 'declined');
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

  decline() {
    let data = {
      'invitation': {
        'decline_reason': this.get('declineReason') || '',
        'reviewer_suggestions': this.get('reviewerSuggestions') || ''
      }
    };

    return this.get('restless')
     .put(`/api/invitations/${this.get('id')}/decline`, data)
     .then((data) => {
       this.feedbackSent();
       return this;
     });
  },

  fetchDetails() {
    return this.get('restless')
     .get(`/api/invitations/${this.get('id')}/details`)
     .then((details) => {
       this.get('store').pushPayload(details);
     });
  },

  feedbackSent() {
    this.set('pendingFeedback', false);
  },

  declineFeedback() {
    this.set('declineReason', null);
    this.set('reviewerSuggestions', null);
    this.set('pendingFeedback', false);
  }
});
