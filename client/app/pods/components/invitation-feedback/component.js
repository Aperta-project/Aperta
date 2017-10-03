import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['invitation-feedback'],

  //init with (data):
  invitation: null,

  //init with (actions):
  decline: null,

  academicEditor: Ember.computed.readOnly('invitation.academicEditor'),
  reviewer: Ember.computed.readOnly('invitation.reviewer'),

  actions: {
    updateDeclineReason(contents) {
      this.set('invitation.declineReason', contents);
    },

    updateReviewerSuggestions(contents) {
      this.set('invitation.reviewerSuggestions', contents);
    },

    declineFeedback(invitation) {
      invitation.declineFeedback();
      return this.get('decline')();
    }
  }
});
