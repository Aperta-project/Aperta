import Ember from 'ember';

export default Ember.Component.extend({
  placeInQueue() {
    // no-op
  },

  linkedInvitations: Ember.computed.filter('invitations.@each.primary', function(inv) {
    return inv.get('alternates.length');
  }),

  sentMainQueueInvitations: Ember.computed.filter('invitations.@each.primary', function(inv) {
    return !inv.get('primary') && !inv.get('alternates.length') && (inv.get('state') !== 'pending');
  }),

  pendingMainQueueInvitations: Ember.computed.filter('invitations.@each.primary', function(inv) {
    return !inv.get('primary') && !inv.get('alternates.length') && (inv.get('state') === 'pending');
  }),

  //queueSorting: ['position'],
  sortedPendingMainQueueInvitations: Ember.computed.sort('pendingMainQueueInvitations', function(invitation) {
    return invitation.position;
  })
});
