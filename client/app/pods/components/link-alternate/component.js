import Ember from 'ember';

export default Ember.Component.extend({
  invitation: null, // passed-in
  classNames: ['invitation-link-alternate'],
  filteredAlternates: Ember.computed.filter('invitations.@each.state', function(invitation) {
    // Reject suggested alternate if itself
    if (invitation === this.get('invitation')) { return false; }

    // Reject if already linked to a primary
    if (invitation.get('primary')) { return false; }

    // Reject if primary has accepted
    if(invitation.get('state') === 'accepted') { return false; }

    // Reject if any any alternates have accepted
    if(invitation.get('alternates').any((inv)=> {
      return inv.get('state') === 'accepted';
    })) { return false; }

    return true;
  }),
  alternateCandidates: Ember.computed('filteredAlternates', function() {
    return this.get('filteredAlternates').map((inv) => {
      return this.inviteeDescription(inv);
    });
  }),
  selectedPrimary: Ember.computed('invitation.primary', function(){
    const inv = this.get('invitation.primary');
    if (inv) {
      return this.inviteeDescription(inv);
    } else {
      return null;
    }
  }),
  inviteeDescription(inv) {
    if (inv.get('invitee.name')) {
      return {
        id: inv,
        text: inv.get('invitee.name') + ' <' + inv.get('email') + '>'
      };
    } else {
      return {
        id: inv,
        text: inv.get('email')
      };
    }
  },

  actions: {
    selectionCleared() {
      this.get('primarySelected')('cleared');
    },
    selectionSelected(selection) {
      this.get('primarySelected')(selection.id);
    }
  }
});
