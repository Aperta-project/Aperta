import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {

  hasInvitations: Ember.computed.notEmpty('invitations'),

  closeOverlay: function() {
    if(!this.get('hasInvitations')) {
      this.get('close')();
    }
  },

  actions: {
    close(){
      this.closeOverlay();
    },

    accept(invitation) {
      this.get('accept')(invitation).then(()=>{this.closeOverlay()});
    },

    aquireFeedback(invitation) {
      invitation.set('pendingFeedback', true);
      this.get('reject')(invitation);
    },

    update(invitation) {
      this.get('update')(invitation).then(()=>{this.closeOverlay()});
    }
  }
});
