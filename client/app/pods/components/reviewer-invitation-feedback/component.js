import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['reviewer-invitation-feedback'],

  //init with (data):
  invitation: null,

  //init with (actions):
  reject: null,

  paper: Ember.computed.alias('invitation.task.paper'),

  actions: {

    declineFeedback(invitation) {
      invitation.set('declineReason', null);
      invitation.set('reviewerSuggestions', null);

      this.sendAction('reject', invitation);
    }
  }
});
