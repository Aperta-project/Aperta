import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {

  hasInvitations: Ember.computed.notEmpty('invitations'),

  actions: {
    close() {
      if(!this.get('hasInvitations')) {
        this.attrs.close();
      }
    },

    accept(invitation) {
      this.attrs.accept(invitation);
      this.close();
    },

    aquireFeedback(invitation) {
      invitation.set('pendingFeedback', true);
      this.reject(invitation);
    },

    reject(invitation) {
      this.attrs.reject(invitation);
      this.close();
    }
  }
});
