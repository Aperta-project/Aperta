import Ember from 'ember';

export default Ember.Controller.extend({
  overlayVisible: true,
  actions: {
    acceptVoucherInvitation() {},
    declineVoucherInvitation(invitation) {
      return invitation.save().then(() => {
        this.toggleProperty('overlayVisible');
        this.transitionToRoute('/');
      });
    },
    hideInvitationsOverlay() {}
  }
});
