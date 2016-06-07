import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';
export default Ember.Component.extend(EscapeListenerMixin, {
  flash: Ember.inject.service(),

  hasInvitations: Ember.computed.notEmpty('invitations'),

  closeOverlayIfLast: function() {
    if(!this.get('hasInvitations')) {
      this.get('close')();
    }
  },

  invitationFeedbackIsBlank: function(invitation) {
    return Ember.isBlank(invitation.get('reviewerSuggestions')) &&
      Ember.isBlank(invitation.get('declineReason'));
  },

  actions: {
    close(){
      this.closeOverlayIfLast();
    },

    accept(invitation) {
      this.get('accept')(invitation).then(()=>{this.closeOverlayIfLast()});
    },

    acquireFeedback(invitation) {
      invitation.set('pendingFeedback', true);
      this.get('reject')(invitation);
    },

    update(invitation) {
      if (this.invitationFeedbackIsBlank(invitation)){
        invitation.feedbackSent();
        return this.closeOverlayIfLast();
      }

      this.get('update')(invitation).then(()=>{
        this.get('flash').displayMessage('success', 'Thank you for your feedback!');
        this.closeOverlayIfLast()});
    }
  }
});
