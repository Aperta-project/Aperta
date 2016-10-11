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
  inviteQueue: DS.belongsTo('inviteQueue', { async: false }),
  invitee: DS.belongsTo('user', { inverse: 'invitations', async: true }),
  inviteeRole: DS.attr('string'),
  position: DS.attr('number'),
  primary: DS.belongsTo('invitation', { inverse: 'alternates', async: false }),
  alternates: DS.hasMany('invitation'),
  reviewerSuggestions: DS.attr('string'),
  state: DS.attr('string'),
  task: DS.belongsTo('task', { polymorphic: true, async: true }),
  title: DS.attr('string'),
  updatedAt: DS.attr('date'),
  invitedAt: DS.attr('date'),
  acceptedAt: DS.attr('date'),
  declinedAt: DS.attr('date'),
  rescindedAt: DS.attr('date'),

  pendingFeedback: false,

  restless: Ember.inject.service('restless'),

  pending: currentState('pending'),
  invited: currentState('invited'),
  accepted: currentState('accepted'),
  declined: currentState('declined'),
  rescinded: currentState('rescinded'),

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
    .then((data) => {
      this.store.pushPayload(data);
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

  feedbackSent() {
    this.set('pendingFeedback', false);
  },

  declineFeedback() {
    this.set('declineReason', null);
    this.set('reviewerSuggestions', null);
    this.set('pendingFeedback', false);
  }
});
