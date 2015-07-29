import Ember from 'ember';

export default Ember.Controller.extend({
  needs: ['dashboard/index'],
  overlayClass: 'overlay--fullscreen invitations-overlay',

  invitations: Ember.computed.reads('currentUser.invitedInvitations'),

  didCompleteAllInvitations: function() {
    if(Ember.isEmpty(this.get('invitations'))) {
      this.send('closeOverlay');
    }
  }.observes('invitations.@each')
});
