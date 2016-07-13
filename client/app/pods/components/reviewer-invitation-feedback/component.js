import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['reviewer-invitation-feedback'],

  //init with (data):
  invitation: null,

  //init with (actions):
  decline: null,

  actions: {
    declineFeedback(invitation) {
      invitation.declineFeedback();
      return this.get('decline')();
    }
  }
});
