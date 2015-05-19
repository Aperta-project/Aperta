import Ember from 'ember';

export default Ember.Controller.extend({
  needs: 'dashboard',
  overlayClass: 'overlay--fullscreen invitations-overlay',
  pendingInvitations: Ember.computed.alias('controllers.dashboard.pendingInvitations'),
  didCompleteAllInvitations: function() {
    if(Ember.isEmpty(this.get('pendingInvitations'))) {
      this.send('closeOverlay');
    }
  }.observes('pendingInvitations.@each')
});
