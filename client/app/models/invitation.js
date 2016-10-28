import Ember from 'ember';
import DS from 'ember-data';

let currentState = function(stateName) {
  return Ember.computed.equal('state', stateName);
};

export default DS.Model.extend({
  abstract: DS.attr('string'),
  attachments: DS.hasMany('invitation-attachment'),
  body: DS.attr('string'),
  createdAt: DS.attr('date'),
  declineReason: DS.attr('string'),
  email: DS.attr('string'),
  information: DS.attr('string'),
  invitationType: DS.attr('string'),
  invitee: DS.belongsTo('user', { inverse: 'invitations' }),
  inviteeRole: DS.attr('string'),
  position: DS.attr('number'),
  primary: DS.belongsTo('invitation', { inverse: 'alternates', async: false }),
  alternates: DS.hasMany('invitation'),
  reviewerSuggestions: DS.attr('string'),
  state: DS.attr('string'),
  task: DS.belongsTo('task', { polymorphic: true }),
  decision: DS.belongsTo('decision', {async: false}),
  title: DS.attr('string'),

  isAlternate: Ember.computed.notEmpty('primary'),
  canReposition: Ember.computed.notEmpty('validNewPositionsForInvitation'),

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

  validNewPositionsForInvitation: DS.attr(),

  invitationFeedbackIsBlank: Ember.computed(
    'reviewerSuggestions',
    'declineReason',
    function() {
      return Ember.isBlank(this.get('reviewerSuggestions')) &&
        Ember.isBlank(this.get('declineReason'));
    }
  ),

  isInvitedOrAccepted: Ember.computed.or('invited', 'accepted'),

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

  updatePrimary(primaryId) {
    return this.get('restless').putUpdate(this, '/update_primary', { primary_id: primaryId });
  },

  changePosition(newPosition) {
    return this.get('restless').putUpdate(this, '/update_position', { position: newPosition });
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
