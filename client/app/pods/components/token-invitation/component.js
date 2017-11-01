import Ember from 'ember';

export default Ember.Component.extend({
  overlayVisible: true,
  declineDone: false,
  notPendingFeedback: Ember.computed.not('model.pendingFeedback'),
  notInvited: Ember.computed.not('model.invited'),
  inactive: Ember.computed.and('notInvited', 'notPendingFeedback'),
  invitations: Ember.computed('model', function(){
    return [this.get('model')];
  }),
  actions: {
    acceptInvitation() {
      window.location.href = `/invitations/${this.get('model.token')}/accept`;
    },
    declineInvitation(invitation) {
      return invitation.save().then(() => {
        this.toggleProperty('declineDone');
      });
    },
    hideInvitationsOverlay() {},
    saveInvitation(invitation){
      invitation.save();
    }
  }
});
