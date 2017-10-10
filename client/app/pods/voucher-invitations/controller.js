import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    acceptVoucherInvitation() {},
    declineVoucherInvitation(invitation) {
      return invitation.save();
    },
    hideInvitationsOverlay() {}
  }
});
