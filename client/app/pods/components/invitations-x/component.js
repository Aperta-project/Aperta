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

  actions: {
    accept(invitation) {
      this.get('accept')(invitation).then(()=>{this.closeOverlayIfLast()});
    },

    acquireFeedback(invitation) {
      invitation.setDeclined();
      invitation.set('pendingFeedback', true);
      if (this.get('acquireFeedback')) { return this.get('acquireFeedback')(invitation); }
    },

    decline(invitation) {
      this.get('decline')(invitation).then(()=>{
        this.get('flash').displayRouteLevelMessage('success', 'Thank you for your feedback!');
        this.closeOverlayIfLast()});
    }
  }
});
