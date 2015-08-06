import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen invitations-overlay',

  invitations: Ember.computed.reads('currentUser.invitedInvitations'),

  didCompleteAllInvitations: Ember.observer('invitations.@each', function() {
    if(Ember.isEmpty(this.get('invitations'))) {
      this.send('closeOverlay');
    }
  })
});
