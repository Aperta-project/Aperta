import Ember from 'ember';

export default Ember.Controller.extend({
  restless: Ember.inject.service('restless'),

  showNewColumnOverlay: false,
  potentialFlows: [],
  isLoadingPotentialFlows: false,

  actions: {
    showNewColumnOverlay() {
      const url = '/api/user_flows/potential_flows';

      this.setProperties({
        isLoadingPotentialFlows: true,
        potentialFlows: [],
        showNewColumnOverlay: true
      });

      this.get('restless').get(url).then(data => {
        this.set('isLoadingPotentialFlows', false);
        this.set('potentialFlows', data.flows);
      });
    },

    hideNewColumnOverlay() {
      this.set('showNewColumnOverlay', false);
    },

    addFlow(flow) {
      this.store.createRecord('user-flow', {
        title: flow.title,
        flowId: flow.id,
        journalName: flow.journal_name,
        journalLogo: flow.journal_logo
      }).save();
    }
  }
});
