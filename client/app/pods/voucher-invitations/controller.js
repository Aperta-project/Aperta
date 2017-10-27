import Ember from 'ember';

export default Ember.Controller.extend({
  overlayVisible: true,
  declineDone: false,
  actions: {
    acceptVoucherInvitation() {},
    declineVoucherInvitation(invitation) {
      return invitation.save().then(() => {
        this.toggleProperty('declineDone');
      });
    },
    hideInvitationsOverlay() {}
  }
});
