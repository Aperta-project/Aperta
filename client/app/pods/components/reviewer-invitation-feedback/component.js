import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['reviewer-invitation-feedback'],

  //init with (data):
  invitation: null,

  //init with (actions):
  update: null,
  close:null,

  actions: {
    declineFeedback(invitation) {
      invitation.set('declineReason', null);
      invitation.set('reviewerSuggestions', null);
      invitation.set('pendingFeedback', false);
      return this.get('close')();
    }
  }
});
