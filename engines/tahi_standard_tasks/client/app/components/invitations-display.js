import Ember from 'ember';

const { computed } = Ember;

export default Ember.Component.extend({
  tagName: 'table',
  classNames: ['invitees'],

  groupByDecision: true,

  invitations: [],

  latestDecision: null,
  latestDecisionInvitations: computed(
    'latestDecision', 'latestDecision.invitations',
    'latestDecision.invitations.[]', function() {
      const type = this.get('invitationType');
      if (this.get('latestDecision.invitations')) {
        return this.get('latestDecision.invitations')
                   .filterBy('invitationType', type);
      }
    }
  ),

  previousDecisions: computed('decisions', function() {
    return this.get('decisions').without(this.get('latestDecision'));
  }),

  previousDecisionsWithFilteredInvitations: computed(
    'previousDecisions', 'previousDecisions.[]', function() {
      return this.get('previousDecisions').map(decision => {
        const allInvitations = decision.get('invitations');
        const type = this.get('invitationType');

        decision.set(
          'filteredInvitations',
          allInvitations.filterBy('invitationType', type)
        );

        return decision;
      });
    }
  ),

  actions: {
    destroyInvitation(invitation) {
      return this.sendAction('onDestroyInvitation', invitation);
    }
  }
});
