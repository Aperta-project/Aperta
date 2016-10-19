import Ember from 'ember';

export default Ember.Component.extend({
  sortCriteria: ['position:asc'],
  sortedInvitations: Ember.computed.sort('invitations', 'sortCriteria'),
  linkedInvitations: Ember.computed.filter('invitations.@each.primary', function(inv) {
    return inv.get('alternates.length');
  }),
});
