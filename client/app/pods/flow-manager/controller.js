import Ember from 'ember';

export default Ember.Controller.extend({
  routing: Ember.inject.service('-routing'),
  restless: Ember.inject.service('restless'),

  taskToDisplay: null,
  showTaskOverlay: false,

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
    },

    viewCard(task) {
      const r = this.get('routing.router.router');

      r.updateURL(
        r.generate('paper.task', task.get('paper.id'), task.get('id'))
      );

      task.get('task').then(t => {
        this.set('taskToDisplay', t);
        this.set('showTaskOverlay', true);
      });
    },

    hideTaskOverlay() {
      const r = this.get('routing.router.router');
      const lastRoute = r.currentHandlerInfos[r.currentHandlerInfos.length - 1];
      r.updateURL(r.generate(lastRoute.name));
      this.set('showTaskOverlay', false);
    }
  }
});
