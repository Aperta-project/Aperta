import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['reviewer-invitation-feedback'],

  //init with (data):
  invitation: null,

  //init with (actions):
  decline: null,

  actions: {
    updateDeclineReason(contents) {
      this.set('declineReason', contents);
    },

    updateReviewerSuggestions(contents) {
      this.set('reviewerSuggestions', contents);
    },

    declineFeedback(invitation) {
      invitation.declineFeedback();
      return this.get('decline')();
    }
  }
});
