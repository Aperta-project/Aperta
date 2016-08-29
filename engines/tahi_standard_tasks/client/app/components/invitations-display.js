import Ember from 'ember';

const { computed } = Ember;

export default Ember.Component.extend({
  groupByDecision: true,

  //TODO: make this a CP
  invitations: [],

  latestDecision: null,
  latestDecisionInvitations: computed(
    'latestDecision.invitations.@each.inviteeRole', function() {
      const type = this.get('inviteeRole');
      if (this.get('latestDecision.invitations')) {
        return this.get('latestDecision.invitations')
                   .filterBy('inviteeRole', type);
      }
    }
  ),

  previousDecisions: computed('decisions', function() {
    return this.get('decisions').without(this.get('latestDecision'));
  }),

  previousDecisionsWithFilteredInvitations: computed(
    'previousDecisions.@each.inviteeRole', function() {
      return this.get('previousDecisions').map(decision => {
        const allInvitations = decision.get('invitations');
        const type = this.get('inviteeRole');

        decision.set(
          'filteredInvitations',
          allInvitations.filterBy('inviteeRole', type)
        );

        return decision;
      });
    }
  ),

  actions: {
    destroyInvitation(invitation) {
      invitation.rescind();
    }
  }
});
