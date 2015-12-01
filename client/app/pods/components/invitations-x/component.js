import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  didCompleteAllInvitations: Ember.observer('invitations.[]', function() {
    if(Ember.isEmpty(this.get('invitations'))) {
      this.attrs.close();
    }
  }),

  actions: {
    close() {
      this.attrs.close();
    },

    accept(invitation) {
      this.attrs.accept(invitation);
    },

    reject(invitation) {
      this.attrs.reject(invitation);
    }
  }
});

