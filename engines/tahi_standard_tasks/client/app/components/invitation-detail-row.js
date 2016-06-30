import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  classNames: 'invitation',
  invitation: null,
  destroyAction: null,

  defaultDeclineResponse: 'n/a',

  invitee: Ember.computed.alias('invitation.invitee'),

  canDestroy: Ember.computed.notEmpty('destroyAction'),
  invitationNotAccepted: Ember.computed.not('invitation.accepted'),
  displayDestroy: Ember.computed.and('canDestroy', 'invitationNotAccepted'),

  declineReason: Ember.computed('invitation.declineReason', function(){
    return this.get('invitation.declineReason') ||
           this.get('defaultDeclineResponse');
  }),

  reviewerSuggestions: Ember.computed('invitation.reviewerSuggestions',
    function(){
      return this.get('invitation.reviewerSuggestions') ||
             this.get('defaultDeclineResponse');
    }
  )
});
