import Ember from 'ember';

export default Ember.Controller.extend({
  needs: ['dashboard/index'],
  overlayClass: 'overlay--fullscreen invitations-overlay',
  pendingInvitations: Ember.computed.alias('controllers.dashboard/index.pendingInvitations'),
  didCompleteAllInvitations: function() {
    if(Ember.isEmpty(this.get('pendingInvitations'))) {
      this.send('closeOverlay');
    }
  }.observes('pendingInvitations.@each')
});
