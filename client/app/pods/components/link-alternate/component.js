import Ember from 'ember';

export default Ember.Component.extend({
  invitation: null, // passed-in
  classNames: ['invitation-link-alternate'],
  filteredAlternates: Ember.computed.filter('invitations.@each.state', function(invitation) {
    if (invitation===this.get('invitation')) { // Reject suggested alternate if itself
      return false;
    }

    if (invitation.get('primary')) { // Reject any alternates already linked to a primary
      return false;
    }
    if(invitation.get('alternates.length')) {
      if(invitation.get('state') === 'accepted') { return false; }
      const altAccepted = invitation.get('alternates').any((inv)=> {
        return inv.get('state') === 'accepted';
      });
      if(altAccepted) {
        return false;
      }
    }
    return true;
  }),
  alternateCandidates: Ember.computed('invitations.[]', function() {
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
