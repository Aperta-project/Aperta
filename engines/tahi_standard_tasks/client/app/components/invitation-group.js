import Ember from 'ember';

export default Ember.Component.extend({
  primariesWithAlternates: Ember.computed.filter('invitations.@each.primary', function(inv) {
    return inv.get('alternates.length');
  }),

  primaries: Ember.computed.filter('invitations.@each.primary', function(inv) {
    return !inv.get('primary') && !inv.get('alternates.length');
  })
});
