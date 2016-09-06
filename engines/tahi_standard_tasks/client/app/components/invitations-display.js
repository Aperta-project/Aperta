import Ember from 'ember';

const { computed } = Ember;

export default Ember.Component.extend({
  groupByDecision: true,
  decisions: null,
  invitations: null,
  latestDecision: null,

  // externally set to allow editing a newly composed invitation
  activeInvitation: null,
  activeInvitationState: null,

  persistedInvitations: computed('invitations.@each.isNew', function() {
    return this.get('invitations').rejectBy('isNew');
  }),

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
  )

});
