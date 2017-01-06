import Ember from 'ember';
const { computed, Mixin } = Ember;

// expects host class to provide a 'decisions' property
export default Mixin.create({
  decisionsAscendingSorting: ['draft', 'majorVersion', 'minorVersion'],

  decisionsAscending: computed.sort('decisions', 'decisionsAscendingSorting'),

  draftDecision: computed('decisions.@each.draft', function() {
    return this.get('decisions').findBy('draft', true);
  }),

  initialDecision: computed(
    'decisions.@each.registeredAt',
    'decisions.@each.rescinded',
    function() {
      let decisions = this.get('sortedDecisions');
      let latestInitial = this.get('decisions')
        .filterBy('initial')
        .filterBy('rescinded', false)
        .get('lastObject');
      // If there's already been a full decision
      // then just return the most recent initial decision.
      let fullDecisions = decisions.filterBy('registeredAt')
        .filterBy('initial', false);
      if (fullDecisions.get('length') > 0) {
        return latestInitial;
      }

      // If all other decisions have been rescinded,
      // return the latest, unmade decision
      let prevCount = decisions.filter((d) => {
        return d.get('registeredAt') && !d.get('rescinded');
      }).get('length');
      if (prevCount === 0) {
        return decisions.findBy('registeredAt', null);
      }

      return latestInitial;
    }),

  latestDecision: computed('decisionsAscending.[]', function() {
    return this.get('decisionsAscending.lastObject');
  }),

  latestRegisteredDecision: computed(
    'decisions.@each.latestRegistered',
    function() {
      return this.get('decisions').findBy('latestRegistered', true);
    }
  ),

  previousDecisions: computed('decisions.@each.registeredAt', function() {
    return this.get('decisions')
      .rejectBy('draft')
      .sortBy('registeredAt')
      .reverseObjects();
  }),

  registeredDecisionsAscending: computed('decisionsAscending.@each.draft', function() {
    return this.get('decisionsAscending').rejectBy('draft');
  }),

  sortedDecisions: computed('decisions.@each.registeredAt', function() {
    return this.get('decisions').sortBy('registeredAt');
  })
});
