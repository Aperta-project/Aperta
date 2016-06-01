import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['reviewer-invitation-feedback'],

  //init with (data):
  invitation: null,

  //init with (actions):
  reject: null,

  actions: {

    declineFeedback(invitation) {
      invitation.set('declineReason', null);
      invitation.set('reviewerSuggestions', null);
      invitation.set('pendingFeedback', false);
      this.get('close')();
    }
  }
});
