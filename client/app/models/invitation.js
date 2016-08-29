import Ember from 'ember';
import DS from 'ember-data';

let currentState = function(stateName) {
  return Ember.computed.equal('state', stateName);
};

export default DS.Model.extend({
  abstract: DS.attr('string'),
  attachments: DS.hasMany('invitation-attachment', { async: true }),
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

  restless: Ember.inject.service('restless'),

  accepted: currentState('accepted'),
  pending: currentState('pending'),
  invited: currentState('invited'),
  declined: currentState('declined'),

  invitationFeedbackIsBlank: Ember.computed(
    'reviewerSuggestions',
    'declineReason',
    function() {
      return Ember.isBlank(this.get('reviewerSuggestions')) &&
        Ember.isBlank(this.get('declineReason'));
    }
  ),

  needsUserUpdate: Ember.computed.or('invited', 'pendingFeedback'),

  setDeclined() {
    this.set('state', 'declined');
  },

  rescind() {
    return this.get('restless')
    .put(`/api/invitations/${this.get('id')}/rescind`)
    .then(() => {
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
     .then(() => {
       this.feedbackSent();
       return this;
     });
  },

  send() {
    return this.get('restless').putUpdate(this, '/send_invite');
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
